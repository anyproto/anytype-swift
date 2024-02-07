import Foundation
import Services

@MainActor
protocol RelationValueCoordinatorProtocol: AnyObject {
    func startFlow(
        objectDetails: ObjectDetails,
        relation: Relation,
        analyticsType: AnalyticsEventsRelationType,
        output: RelationValueCoordinatorOutput
    )
}
