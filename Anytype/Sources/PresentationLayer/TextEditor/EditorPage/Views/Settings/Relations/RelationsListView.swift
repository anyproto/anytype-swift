import SwiftUI
import BlocksModels

struct RelationsListView: View {
    
    @ObservedObject var viewModel: RelationsListViewModel
    
    @State private var editingMode = false
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator(bottomPadding: 0)
            navigationBar
            relationsList
        }
    }
    
    private var navigationBar: some View {
        HStack {
            Button {
                withAnimation(.fastSpring) {
                    editingMode.toggle()
                }
            } label: {
                AnytypeText(editingMode ? "Done".localized : "Edit".localized, style: .uxBodyRegular, color: .textSecondary)
            }

            Spacer()
        }
        .frame(height: 48)
        .padding(.horizontal, 16)
    }
    
    private var relationsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.sections) { section in
                    VStack(alignment: .leading, spacing: 0) {
                        Section(
                            header: AnytypeText(
                                section.title,
                                style: .uxTitle1Semibold,
                                color: .textPrimary
                            )
                                .padding(.vertical, 12)
                        ) {
                            ForEach(section.relations) { relation in
                                RelationsListRowView(editingMode: $editingMode, relation: relation) {
                                    viewModel.removeRelation(id: $0)
                                } onStarTap: {
                                    viewModel.changeRelationFeaturedState(relationId: $0)
                                } onEditTap: {
                                    viewModel.onValueEditingTap($0)
                                }
                            }
                        }
                        
                        Spacer()
                            .frame(height: 20)
                    }
                    
                }
            }.padding(.horizontal, 20)
        }
    }
    
}

struct ObjectRelationsView_Previews: PreviewProvider {
        
    static var previews: some View {
        RelationsListView(
            viewModel: RelationsListViewModel(
                source: .object,
                relationsService: RelationsService(objectId: ""),
                sections: [
                    RelationsSection(
                        id: "id",
                        title: "title",
                        relations: [
                            Relation.text(
                                Relation.Text(
                                    id: "id",
                                    name: "name",
                                    isFeatured: false,
                                    isEditable: true,
                                    isBundled: false,
                                    value: "text"
                                )
                            ),
                            Relation.text(
                                Relation.Text(
                                    id: "id2",
                                    name: "name",
                                    isFeatured: false,
                                    isEditable: true,
                                    isBundled: false,
                                    value: "text"
                                )
                            ),
                            Relation.tag(
                                Relation.Tag(
                                    id: "id3",
                                    name: "name",
                                    isFeatured: false,
                                    isEditable: true,
                                    isBundled: false,
                                    selectedTags: [
                                        Relation.Tag.Option(
                                            id: "id1",
                                            text: "text1",
                                            textColor: UIColor.Text.teal,
                                            backgroundColor: UIColor.TagBackground.default,
                                            scope: .local
                                        ),
                                        Relation.Tag.Option(
                                            id: "id2",
                                            text: "text2",
                                            textColor: UIColor.Text.red,
                                            backgroundColor: UIColor.Background.red,
                                            scope: .local
                                        ),
                                        Relation.Tag.Option(
                                            id: "id3",
                                            text: "text3",
                                            textColor: UIColor.Text.teal,
                                            backgroundColor: UIColor.Background.teal,
                                            scope: .local
                                        ),
                                        Relation.Tag.Option(
                                            id: "id4",
                                            text: "text4",
                                            textColor: UIColor.Text.red,
                                            backgroundColor: UIColor.Background.red,
                                            scope: .local
                                        )
                                    ],
                                    allTags: [
                                        Relation.Tag.Option(
                                            id: "id1",
                                            text: "text1",
                                            textColor: UIColor.Text.teal,
                                            backgroundColor: UIColor.TagBackground.default,
                                            scope: .local
                                        ),
                                        Relation.Tag.Option(
                                            id: "id2",
                                            text: "text2",
                                            textColor: UIColor.Text.red,
                                            backgroundColor: UIColor.Background.red,
                                            scope: .local
                                        ),
                                        Relation.Tag.Option(
                                            id: "id3",
                                            text: "text3",
                                            textColor: UIColor.Text.teal,
                                            backgroundColor: UIColor.Background.teal,
                                            scope: .local
                                        ),
                                        Relation.Tag.Option(
                                            id: "id4",
                                            text: "text4",
                                            textColor: UIColor.Text.red,
                                            backgroundColor: UIColor.Background.red,
                                            scope: .local
                                        )
                                    ]
                                )
                            )
                        ]
                    ),
                    RelationsSection(
                        id: "id1",
                        title: "title2",
                        relations: [
                            Relation.text(
                                Relation.Text(
                                    id: "id23",
                                    name: "name",
                                    isFeatured: false,
                                    isEditable: true,
                                    isBundled: false,
                                    value: "text"
                                )
                            ),
                            Relation.text(
                                Relation.Text(
                                    id: "id21",
                                    name: "name",
                                    isFeatured: false,
                                    isEditable: true,
                                    isBundled: false,
                                    value: "text"
                                )
                            ),
                            Relation.text(
                                Relation.Text(
                                    id: "id22",
                                    name: "name",
                                    isFeatured: false,
                                    isEditable: true,
                                    isBundled: false,
                                    value: "text"
                                )
                            )
                        ]
                    )
                ],
                onValueEditingTap: { _ in }
            )
        )
    }
}
