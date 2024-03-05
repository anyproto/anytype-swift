import Foundation
import Services

@MainActor
protocol LegacyRelationValueCoordinatorProtocol: AnyObject {
    func startFlow12(
        objectDetails: ObjectDetails,
        relation: Relation,
        analyticsType: AnalyticsEventsRelationType,
        output: RelationValueCoordinatorOutput
    )
}
