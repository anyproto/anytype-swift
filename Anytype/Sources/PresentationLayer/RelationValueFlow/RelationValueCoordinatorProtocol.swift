import Foundation
import Services

protocol RelationValueCoordinatorProtocol: AnyObject {
    func startFlow(
        objectId: BlockId,
        relation: Relation,
        analyticsType: AnalyticsEventsRelationType,
        output: RelationValueCoordinatorOutput
    )
}
