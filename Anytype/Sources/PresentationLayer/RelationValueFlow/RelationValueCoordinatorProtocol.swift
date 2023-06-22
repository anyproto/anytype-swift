import Foundation
import Services

protocol RelationValueCoordinatorProtocol: AnyObject {
    func startFlow(
        objectDetails: ObjectDetails,
        relation: Relation,
        analyticsType: AnalyticsEventsRelationType,
        output: RelationValueCoordinatorOutput
    )
}
