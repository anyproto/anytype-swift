import Foundation
import UIKit
import BlocksModels

#warning("Check if block updates when featuredRelations is changed. Waiting for new imp of flow layout")
struct FeaturedRelationsBlockViewModel: BlockViewModelProtocol {
    let indentationLevel: Int = 0
    let info: BlockInformation
    let type: String
    var featuredRelations: [Relation]
    let onRelationTap: (Relation) -> Void
    
    var hashable: AnyHashable {
        [
            indentationLevel,
            info,
            type,
            featuredRelations
        ] as [AnyHashable]
    }
    
    init(
        info: BlockInformation,
        featuredRelation: [Relation],
        type: String,
        onRelationTap: @escaping (Relation) -> Void
    ) {
        self.info = info
        self.featuredRelations = featuredRelation
        self.type = type
        self.onRelationTap = onRelationTap
    }
    
    func makeContentConfiguration(maxWidth _: CGFloat) -> UIContentConfiguration {
        FeaturedRelationsBlockContentConfiguration(
            featuredRelations: featuredRelations,
            type: type,
            alignment: info.alignment.asNSTextAlignment,
            onRelationTap: onRelationTap
        ).asCellBlockConfiguration
    }
    
    func didSelectRowInTableView() {}
}
