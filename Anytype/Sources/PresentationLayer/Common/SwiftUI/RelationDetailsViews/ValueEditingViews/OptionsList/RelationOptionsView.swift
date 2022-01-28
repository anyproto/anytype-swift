import SwiftUI

struct RelationOptionsView: View {
    
    @ObservedObject var viewModel: RelationOptionsViewModel
        
    @State private var isSearchPresented: Bool = false
    
    var body: some View {
        NavigationView {
            content
                .navigationTitle(viewModel.title)
                .navigationBarTitleDisplayMode(.inline)
                .sheet(isPresented: $isSearchPresented) { viewModel.makeSearchView() }
        }
    }
    
    private var content: some View {
        Group {
            if viewModel.selectedOptions.isEmpty {
                emptyView
            } else {
                optionsList
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                addButton
            }
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 0) {
            AnytypeText(viewModel.emptyPlaceholder, style: .uxCalloutRegular, color: .textTertiary)
                .padding(.vertical, 13)
            Spacer.fixedHeight(20)
        }
    }
    
    private var optionsList: some View {
        List {
            ForEach(viewModel.selectedOptions, id: \.id) { $0.makeView() }
            .onMove { source, destination in
                viewModel.move(source: source, destination: destination)
            }
            .onDelete {
                viewModel.delete($0)
            }
        }
        .padding(.bottom, 20)
        .listStyle(.plain)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
                    .foregroundColor(Color.strokePrimary)
            }
        }
    }
    
}

// MARK: - NavigationBarView

private extension RelationOptionsView {
    var addButton: some View {
        Button {
            isSearchPresented = true
        } label: {
            Image.Relations.createOption.frame(width: 24, height: 24)
        }
    }
    
}
//struct RelationOptionsView_Previews: PreviewProvider {
//    static var previews: some View {
//        RelationOptionsView()
//    }
//}
