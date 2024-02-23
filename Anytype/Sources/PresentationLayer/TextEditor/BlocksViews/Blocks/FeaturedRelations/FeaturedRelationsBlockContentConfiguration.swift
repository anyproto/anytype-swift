import UIKit
import Services

struct FeaturedRelationsBlockContentConfiguration: BlockConfiguration {
    typealias View = FeaturedRelationBlockView

    let featuredRelations: [Relation]
    let type: String
    let alignment: NSTextAlignment

    @EquatableNoop private(set) var onRelationTap: (Relation) -> Void
}

extension FeaturedRelationsBlockContentConfiguration {
    var isAnimationEnabled: Bool { false }
}
