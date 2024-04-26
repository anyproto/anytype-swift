import UIKit
import Services

struct FeaturedRelationsBlockContentConfiguration: BlockConfiguration {
    typealias View = FeaturedRelationBlockView

    let featuredRelations: [RelationItemModel]
    let type: String
    let alignment: NSTextAlignment

    @EquatableNoop private(set) var onRelationTap: (RelationItemModel) -> Void
    @EquatableNoop var heightDidChanged: () -> Void
}

extension FeaturedRelationsBlockContentConfiguration {
    var isAnimationEnabled: Bool { false }
}
