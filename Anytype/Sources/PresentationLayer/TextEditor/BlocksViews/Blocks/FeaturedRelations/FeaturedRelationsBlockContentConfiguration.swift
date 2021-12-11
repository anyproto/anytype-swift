import UIKit
import BlocksModels

struct FeaturedRelationsBlockContentConfiguration: BlockConfigurationProtocol, Hashable {
    let featuredRelations: [NewRelation]
    let type: String
    let alignment: NSTextAlignment
    var currentConfigurationState: UICellConfigurationState?
    let onRelationTap: (NewRelation) -> Void

    func makeContentView() -> UIView & UIContentView {
        FeaturedRelationsBlockView(configuration: self)
    }

    static func == (lhs: FeaturedRelationsBlockContentConfiguration, rhs: FeaturedRelationsBlockContentConfiguration) -> Bool {
        lhs.featuredRelations == rhs.featuredRelations &&
        lhs.type == rhs.type &&
        lhs.alignment == rhs.alignment &&
        lhs.currentConfigurationState == rhs.currentConfigurationState
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(featuredRelations)
        hasher.combine(type)
        hasher.combine(alignment)
        hasher.combine(currentConfigurationState)
    }
}
