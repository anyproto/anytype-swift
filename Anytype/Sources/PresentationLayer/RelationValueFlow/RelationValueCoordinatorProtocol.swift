import Foundation
import BlocksModels

protocol RelationValueCoordinatorProtocol: AnyObject {
    func startFlow(
        objectId: BlockId,
        source: RelationSource,
        relationValue: RelationValue,
        output: RelationValueCoordinatorOutput
    )
}
