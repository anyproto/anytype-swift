import Foundation
import BlocksModels

protocol RelationValueCoordinatorProtocol: AnyObject {
    func startFlow(
        objectId: BlockId,
        relation: Relation,
        output: RelationValueCoordinatorOutput
    )
}
