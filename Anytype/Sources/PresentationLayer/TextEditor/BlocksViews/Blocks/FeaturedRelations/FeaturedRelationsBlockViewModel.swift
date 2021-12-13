import Foundation
import UIKit
import BlocksModels

// TODO: Check if block updates when featuredRelations is changed
struct FeaturedRelationsBlockViewModel: BlockViewModelProtocol {
    var upperBlock: BlockModelProtocol?

    let indentationLevel: Int = 0
    let information: BlockInformation
    let type: String
    var featuredRelations: [NewRelation]
    let onRelationTap: (NewRelation) -> Void
    
    var hashable: AnyHashable {
        [
            indentationLevel,
            information,
            type
        ] as [AnyHashable]
    }
    
    init(
        information: BlockInformation,
        featuredRelation: [NewRelation],
        type: String,
        onRelationTap: @escaping (NewRelation) -> Void
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
