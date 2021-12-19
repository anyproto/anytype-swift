import SwiftUI

// TODO: - add button / edit button

struct TagRelationEditingView: View {
    
    @ObservedObject var viewModel: TagRelationEditingViewModel
    
    @Environment(\.editMode) private var editMode: Binding<EditMode>?
    
    @State private var isSearchOpen: Bool = false
    
    var body: some View {
        content
            .modifier(
                RelationSheetModifier(isPresented: $viewModel.isPresented, title: nil, dismissCallback: viewModel.dismissHandler)
            )
            .sheet(isPresented: $isSearchOpen) {
                TagRelationOptionSearchView(viewModel: viewModel.searchViewModel)
            }
    }
    
    private var content: some View {
        Group {
            if viewModel.selectedTags.isEmpty {
                emptyView
            } else {
                NavigationView {
                    tagsList
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
            AnytypeText("No related options here. You can add some".localized, style: .uxCalloutRegular, color: .textTertiary)
                .padding(.vertical, 13)
            Spacer.fixedHeight(20)
        }
    }
    
    private var tagsList: some View {
        List {
            ForEach(viewModel.selectedTags) { tag in
                TagRelationRowView(tag: tag)
            }
            .onMove { source, destination in
                viewModel.postponeEditingAction(.move(source, destination))
            }
            .onDelete { viewModel.postponeEditingAction(.remove($0)) }
        }
        .padding(.bottom, 20)
        .listStyle(.plain)
    }
        
    private var editButton: some View {
        Button {
            withAnimation(.fastSpring) {
                if let value = self.editMode?.wrappedValue, value == .active {
                    viewModel.applyEditingActions()
                }
                self.editMode?.wrappedValue.toggle()
            }
        } label: {
            AnytypeText(self.editMode?.wrappedValue == .active ? "Done" : "Edit", style: .uxBodyRegular, color: .grayscale50)
        }
    }
    
    private var addButton: some View {
        Button {
            isSearchOpen = true
        } label: {
            Image.Relations.createOption.frame(width: 24, height: 24)
        }

    }
}

extension EditMode {

    mutating func toggle() {
        self = self == .active ? .inactive : .active
    }
}

struct TagRelationEditingView_Previews: PreviewProvider {
    static var previews: some View {
        TagRelationEditingView(
            viewModel: TagRelationEditingViewModel(
                relationTag: Relation.Tag(
                    id: "",
                    name: "name",
                    isFeatured: false,
                    isEditable: true,
                    selectedTags: [
                        Relation.Tag.Option(
                            id: "id",
                            text: "text",
                            textColor: .darkAmber,
                            backgroundColor: .lightAmber,
                            scope: .local
                        ),
                        Relation.Tag.Option(
                            id: "id3",
                            text: "text3",
                            textColor: .darkAmber,
                            backgroundColor: .lightAmber,
                            scope: .local
                        ),
                        Relation.Tag.Option(
                            id: "id2",
                            text: "text2",
                            textColor: .darkAmber,
                            backgroundColor: .lightAmber,
                            scope: .local
                        )
                    ],
                    allTags: [
                        Relation.Tag.Option(
                            id: "id",
                            text: "text",
                            textColor: .darkAmber,
                            backgroundColor: .lightAmber,
                            scope: .local
                        ),
                        Relation.Tag.Option(
                            id: "id3",
                            text: "text3",
                            textColor: .darkAmber,
                            backgroundColor: .lightAmber,
                            scope: .local
                        ),
                        Relation.Tag.Option(
                            id: "id2",
                            text: "text2",
                            textColor: .darkAmber,
                            backgroundColor: .lightAmber,
                            scope: .local
                        )
                    ]
                ),
                detailsService: DetailsService(objectId: ""),
                relationsService: RelationsService(objectId: "")
            )
        )
    }
}
