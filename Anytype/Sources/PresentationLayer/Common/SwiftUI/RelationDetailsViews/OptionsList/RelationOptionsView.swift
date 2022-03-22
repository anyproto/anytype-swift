import SwiftUI

struct RelationOptionsView: View {
    
    @ObservedObject var viewModel: RelationOptionsViewModel
            
    var body: some View {
        NavigationView {
            content
                .navigationTitle(viewModel.title)
                .navigationBarTitleDisplayMode(.inline)
                .sheet(isPresented: $viewModel.isSearchPresented) { viewModel.makeSearchView() }
        }
        .navigationViewStyle(.stack)
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
                .frame(height: 48)
            Spacer()
        }
    }
    
    private var optionsList: some View {
        List {
            ForEach(viewModel.selectedOptions) {
                $0.makeView()
            }
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
                    .foregroundColor(Color.buttonActive)
            }
        }
    }
    
}

// MARK: - NavigationBarView

private extension RelationOptionsView {
    
    var addButton: some View {
        Button {
            viewModel.didTapAddButton()
        } label: {
            Image.Relations.createOption.frame(width: 24, height: 24)
        }
    }
    
}
