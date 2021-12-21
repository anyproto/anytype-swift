import SwiftUI

struct RelationObjectsEditingView: View {
    
    @ObservedObject var viewModel: RelationObjectsEditingViewModel
    
    @Environment(\.editMode) private var editMode: Binding<EditMode>?
    
    var body: some View {
        content
            .modifier(
                RelationSheetModifier(isPresented: $viewModel.isPresented, title: nil, dismissCallback: viewModel.dismissHandler)
            )
    }
    
    private var content: some View {
        Group {
            if viewModel.selectedObjects.isEmpty {
                emptyView
            } else {
                NavigationView {
                    objectsList
                        .navigationBarTitle(viewModel.relationName, displayMode: .inline)
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
            AnytypeText("Empty".localized, style: .uxCalloutRegular, color: .textTertiary)
                .padding(.vertical, 13)
            Spacer.fixedHeight(20)
        }
    }
    
    private var objectsList: some View {
        List {
            ForEach(viewModel.selectedObjects) { RelationObjectsRowView(object: $0) }
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
    
    private var addButton: some View {
        Button {
//            isSearchOpen = true
        } label: {
            Image.Relations.createOption.frame(width: 24, height: 24)
        }
    }
}

struct RelationObjectsEditingView_Previews: PreviewProvider {
    static var previews: some View {
        RelationObjectsEditingView(
            viewModel: RelationObjectsEditingViewModel(
                relationObject: Relation.Object(
                    id: "",
                    name: "Cast",
                    isFeatured: false,
                    isEditable: true,
                    selectedObjects: [
                        Relation.Object.Option(
                            id: "1",
                            icon: .todo(false),
                            title: "title",
                            type: "type"
                        ),
                        Relation.Object.Option(
                            id: "2",
                            icon: .todo(false),
                            title: "title2",
                            type: "type2"
                        ),
                        Relation.Object.Option(
                            id: "3",
                            icon: .todo(false),
                            title: "title3",
                            type: "type3"
                        )
                    ]
                ),
                relationsService: RelationsService(objectId: "")
            )
        )
    }
}
