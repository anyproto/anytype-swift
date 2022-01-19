import SwiftUI

struct RelationOptionsView: View {
    
    @ObservedObject var viewModel: RelationOptionsViewModel
    
    @Environment(\.editMode) private var editMode: Binding<EditMode>?
    
    @State private var isSearchPresented: Bool = false
    
    var body: some View {
        content
            .sheet(isPresented: $isSearchPresented) { viewModel.makeSearchView() }
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            navigationBarView
            if viewModel.selectedOptions.isEmpty {
                emptyView
            } else {
                optionsList
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
                viewModel.postponeEditingAction(.move(source, destination))
            }
            .onDelete {
                viewModel.postponeEditingAction(.remove($0))
            }
        }
        .padding(.bottom, 20)
        .listStyle(.plain)
    }
    
}

// MARK: - NavigationBarView

private extension RelationOptionsView {
    
    var navigationBarView: some View {
        HStack(alignment: .center, spacing: 0) {
            leadingNavigationBarView
            
            AnytypeText(viewModel.title, style: .uxTitle1Semibold, color: .textPrimary)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
            
            trailingNavigationBarView
        }
        .frame(height: 48)
        .padding(.horizontal, 16)
        
    }
    
    var leadingNavigationBarView: some View {
        HStack(spacing: 0) {
            editButton
                .if(viewModel.selectedOptions.isEmpty) {
                    $0.hidden()
                }
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    var editButton: some View {
        Button {
            withAnimation(.fastSpring) {
                if let value = editMode?.wrappedValue, value == .active {
                    viewModel.applyEditingActions()
                }
                editMode?.wrappedValue.toggle()
            }
        } label: {
            AnytypeText(editMode?.wrappedValue == .active ? "Done".localized : "Edit".localized, style: .uxBodyRegular, color: .grayscale50)
        }
    }
    
    var trailingNavigationBarView: some View {
        HStack(spacing: 0) {
            Spacer()
            addButton
                .if(editMode?.wrappedValue == .active) {
                    $0.hidden()
                }
        }
        .frame(maxWidth: .infinity)
    }
    
    var addButton: some View {
        Button {
            isSearchPresented = true
        } label: {
            Image.Relations.createOption.frame(width: 24, height: 24)
        }
    }
    
}

private extension EditMode {

    mutating func toggle() {
        self = self == .active ? .inactive : .active
    }
}

//struct RelationOptionsView_Previews: PreviewProvider {
//    static var previews: some View {
//        RelationOptionsView()
//    }
//}
