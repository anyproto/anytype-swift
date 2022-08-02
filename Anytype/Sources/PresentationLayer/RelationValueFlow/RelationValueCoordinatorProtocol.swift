import Foundation
import BlocksModels

protocol RelationValueCoordinatorProtocol: AnyObject {
    func startFlow(
        objectId: BlockId,
        source: RelationSource,
        relation: Relation,
        output: RelationValueCoordinatorOutput
    )
}
