import SwiftUI
import WrappingHStack

enum FeaturedPropertiesConstants {
    static let itemSpacing: CGFloat = 6
    static let lineSpacing: CGFloat = 4
}

struct FeaturedPropertiesView<Content>: View where Content: View {
    let relations: [Property]
    let view: (Property) -> Content
    
    var body: some View {
        WrappingHStack(
            alignment: .leading,
            horizontalSpacing: FeaturedPropertiesConstants.itemSpacing,
            verticalSpacing: FeaturedPropertiesConstants.lineSpacing
        ) {
            ForEach(relations) { relation in
                HStack(spacing: FeaturedPropertiesConstants.itemSpacing) {
                    view(relation)
                    
                    if !isLastRelation(relation) {
                        divider
                    }
                }
            }
        }
    }
    
    private var divider: some View {
        Circle()
            .fill(Color.Text.secondary)
            .frame(width: 3, height: 3)
    }
    
    private func isLastRelation(_ relation: Property) -> Bool {
        relations.last?.id == relation.id
    }
}
