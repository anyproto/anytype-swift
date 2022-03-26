import SwiftUI
import BlocksModels

struct RelationsListView: View {
    
    @ObservedObject var viewModel: RelationsListViewModel
    @State private var editingMode = false
    
    @State private var isCreateNewRelatinPresented = false
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            navigationBar
            relationsList
        }
        .sheet(isPresented: $isCreateNewRelatinPresented) {
            SearchNewRelationView(viewModel: viewModel.searchNewRelationViewModel)
        }
    }
    
    private var navigationBar: some View {
        HStack {
            editButton
            Spacer()
            createNewRelationButton
        }
        .frame(height: 48)
        .padding(.horizontal, 16)
    }
    
    private var editButton: some View {
        Button {
            withAnimation(.fastSpring) {
                editingMode.toggle()
            }
        } label: {
            AnytypeText(editingMode ? "Done".localized : "Edit".localized, style: .uxBodyRegular, color: .textSecondary)
        }
    }
    
    private var createNewRelationButton: some View {
        Button {
            isCreateNewRelatinPresented = true
        } label: {
            Image.Relations.createOption.frame(width: 24, height: 24)
        }
    }
    
    private var relationsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.sections) { section in
                    VStack(alignment: .leading, spacing: 0) {
                        
                        Section(header: sectionHeader(title: section.title)) {
                            ForEach(section.relations) {
                                row(with: $0)
                            }
                        }
                        
                        Spacer().frame(height: 20)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func sectionHeader(title: String) -> some View {
        AnytypeText(title, style: .uxTitle1Semibold, color: .textPrimary)
            .frame(height: 48)
    }
    
    private func row(with relation: Relation) -> some View {
        RelationsListRowView(editingMode: $editingMode, relation: relation) {
            viewModel.removeRelation(id: $0)
        } onStarTap: {
            viewModel.changeRelationFeaturedState(relationId: $0)
        } onEditTap: {
            viewModel.onValueEditingTap($0)
        }
    }
    
}

struct ObjectRelationsView_Previews: PreviewProvider {
        
    static var previews: some View {
        RelationsListView(
            viewModel: RelationsListViewModel(
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
                                    format: .longText,
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
                                    format: .longText,
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
                                    format: .shortText,
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
                                    format: .shortText,
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
                                    format: .shortText,
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
                                    format: .shortText,
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
