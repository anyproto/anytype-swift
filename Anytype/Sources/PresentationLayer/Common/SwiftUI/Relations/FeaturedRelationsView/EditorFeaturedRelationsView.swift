import SwiftUI

final class EditorFeaturedRelationsViewModel: ObservableObject {
    
    @Published var relations: [Relation] = []
    var onRelationTap: ((Relation) -> Void)? = nil
    
    func updateRelations(_ relations: [Relation]) {
        self.relations = relations
    }
    
    func onRelationTap(_ relation: Relation) {
        onRelationTap?(relation)
    }
}

struct EditorFeaturedRelationsView: View {
    @StateObject var model: EditorFeaturedRelationsViewModel
    
    var body: some View {
        FeaturedRelationsView(
            relations: model.relations,
            view: { relation in
                RelationValueView(
                    model: RelationValueViewModel(
                        relation:  RelationItemModel(relation: relation),
                        style: .featuredRelationBlock(
                            FeaturedRelationSettings(
                                allowMultiLine: false,
                                error: RelationItemModel(relation: relation).isErrorState,
                                links: relation.links
                            )
                        ),
                        mode: .button(action: { model.onRelationTap(relation) })
                    )
                )
            }
        )
    }
}
