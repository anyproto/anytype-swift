import Foundation
import UIKit
import BlocksModels

#warning("Check if block updates when featuredRelations is changed")
struct FeaturedRelationsBlockViewModel: BlockViewModelProtocol {
    let indentationLevel: Int = 0
    let information: BlockInformation
    let type: String
    var featuredRelations: [Relation]
    let onRelationTap: (Relation) -> Void
    
    var hashable: AnyHashable {
        [
            indentationLevel,
            information,
            type,
            featuredRelations
        ] as [AnyHashable]
    }
    
    init(
        information: BlockInformation,
        featuredRelation: [Relation],
        type: String,
        onRelationTap: @escaping (Relation) -> Void
    ) {
        self.information = information
        self.featuredRelations = featuredRelation
        self.type = type
        self.onRelationTap = onRelationTap
    }
    
    func makeContentConfiguration(maxWidth _: CGFloat) -> UIContentConfiguration {
        FeaturedRelationsBlockContentConfiguration(
            featuredRelations: featuredRelations,
            type: type,
            alignment: information.alignment.asNSTextAlignment,
            onRelationTap: onRelationTap
        )
    }
    
    func didSelectRowInTableView() {}
}
