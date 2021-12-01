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
                                    viewModel.editRelation(id: $0)
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
                relationsService: RelationsService(objectId: ""),
                sections: [
                    RelationsSection(
                        id: "id",
                        title: "title",
                        relations: [
                            Relation(
                                id: "1",
                                name: "Relation name1",
                                value: .text("text"),
                                hint: "hint",
                                isFeatured: false,
                                isEditable: true
                                
                            ),
                            Relation(
                                id: "2",
                                name: "Relation name2",
                                value: .text("text2"),
                                hint: "hint",
                                isFeatured: false,
                                isEditable: true
                            ),
                            Relation(
                                id: "3",
                                name: "Relation name3",
                                value: .tag([
                                    TagRelationValue(text: "text", textColor: .darkTeal, backgroundColor: .grayscaleWhite),
                                    TagRelationValue(text: "text2", textColor: .darkRed, backgroundColor: .lightRed),
                                    TagRelationValue(text: "text", textColor: .darkTeal, backgroundColor: .lightTeal),
                                    TagRelationValue(text: "text2", textColor: .darkRed, backgroundColor: .lightRed)
                                ]),
                                hint: "hint",
                                isFeatured: false,
                                isEditable: true
                            )
                        ]
                    ),
                    RelationsSection(
                        id: "id1",
                        title: "title2",
                        relations: [
                            Relation(
                                id: "12",
                                name: "Relation name1",
                                value: .text("text"),
                                hint: "hint",
                                isFeatured: false,
                                isEditable: true
                            ),
                            Relation(
                                id: "22",
                                name: "Relation name2",
                                value: .text("text2"),
                                hint: "hint",
                                isFeatured: false,
                                isEditable: true
                            ),
                            Relation(
                                id: "32",
                                name: "Relation name3",
                                value: .text("text3"),
                                hint: "hint",
                                isFeatured: false,
                                isEditable: true
                            )
                        ]
                    )
                ],
                onValueEditingTap: { _ in }
            )
        )
    }
}
