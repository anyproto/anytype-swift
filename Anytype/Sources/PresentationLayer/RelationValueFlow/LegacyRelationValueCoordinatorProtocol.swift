import Foundation
import Services

@MainActor
protocol LegacyRelationValueCoordinatorProtocol: AnyObject {
    func startFlow(
        objectDetails: ObjectDetails,
        relation: Relation,
        analyticsType: AnalyticsEventsRelationType,
        output: RelationValueCoordinatorOutput
    )
}
