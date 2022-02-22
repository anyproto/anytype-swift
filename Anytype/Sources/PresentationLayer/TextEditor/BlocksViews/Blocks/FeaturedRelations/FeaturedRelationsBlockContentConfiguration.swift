import UIKit
import BlocksModels

struct FeaturedRelationsBlockContentConfiguration: BlockConfiguration {
    typealias View = FeaturedRelationsBlockView

    let featuredRelations: [Relation]
    let type: String
    let alignment: NSTextAlignment
    @EquatableNoop private(set) var onRelationTap: (Relation) -> Void
}
