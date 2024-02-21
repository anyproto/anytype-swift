import SwiftUI
import WrappingHStack

enum FeaturedRelationsConstants {
    static let itemSpacing: CGFloat = 6
    static let lineSpacing: CGFloat = 4
}

struct FeaturedRelationsView<Content>: View where Content: View {
    let relations: [Relation]
    let view: (Relation) -> Content
    
    var body: some View {
        WrappingHStack(
            relations,
            spacing: .constant(FeaturedRelationsConstants.itemSpacing),
            lineSpacing: FeaturedRelationsConstants.lineSpacing
        ) { relation in
            HStack(spacing: FeaturedRelationsConstants.itemSpacing) {
                view(relation)
                
                if !isLastRelation(relation) {
                    divider
                }
            }
        }
    }
    
    private var divider: some View {
        Circle()
            .fill(Color.Text.secondary)
            .frame(width: 3, height: 3)
    }
    
    private func isLastRelation(_ relation: Relation) -> Bool {
        relations.last?.id == relation.id
    }
}
