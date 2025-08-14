import SwiftUI

struct EditorFeaturedPropertiesView: View {
    let relations: [Property]
    let onRelationTap: ((Property) -> Void)
    
    init(relations: [Property], onRelationTap: @escaping (Property) -> Void) {
        self.relations = relations
        self.onRelationTap = onRelationTap
    }
    
    var body: some View {
        if relations.isNotEmpty {
            content
        }
    }
    
    private var content: some View {
        FeaturedPropertiesView(
            relations: relations,
            view: { relation in
                PropertyValueView(
                    model: PropertyValueViewModel(
                        property:  PropertyItemModel(property: relation),
                        style: .featuredBlock(
                            FeaturedPropertySettings(
                                allowMultiLine: false,
                                error: PropertyItemModel(property: relation).isErrorState,
                                links: relation.links
                            )
                        ),
                        mode: .button(action: { onRelationTap(relation) })
                    )
                )
            }
        )
        .padding(.top, 8)
    }
}
