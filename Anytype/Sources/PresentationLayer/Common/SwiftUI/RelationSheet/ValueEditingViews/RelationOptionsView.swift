import SwiftUI

struct RelationOptionsView: View {
    
    @ObservedObject var viewModel: RelationOptionsViewModel
    
    @Environment(\.editMode) private var editMode: Binding<EditMode>?
    
    @State private var isSearchPresented: Bool = false
    
    var body: some View {
        content
            .modifier(
                RelationSheetModifier(isPresented: $viewModel.isPresented, title: nil, dismissCallback: viewModel.dismissHandler)
            )
//            .sheet(isPresented: $isSearchPresented) {
//                RelationObjectsSearchView(viewModel: viewModel.relationObjectsSearchViewModel)
//            }
    }
    
    #warning("TODO: Custom nav bar")
    private var content: some View {
        Group {
            if viewModel.selectedOptions.isEmpty {
                emptyView
            } else {
                NavigationView {
                    optionsList
                        .navigationBarTitle(viewModel.title, displayMode: .inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) { editButton }
                            ToolbarItem(placement: .navigationBarTrailing) { addButton }
                        }
                        
                }
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
    
    private var editButton: some View {
        Group {
            if viewModel.selectedOptions.isEmpty {
                EmptyView()
            } else {
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
        }
        
    }
    
    private var addButton: some View {
        Button {
            isSearchPresented = true
        } label: {
            Image.Relations.createOption.frame(width: 24, height: 24)
        }.disabled(editMode?.wrappedValue == .active)
    }
}

//struct RelationOptionsView_Previews: PreviewProvider {
//    static var previews: some View {
//        RelationOptionsView()
//    }
//}
