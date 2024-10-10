import Foundation
import Services

protocol ObjectsCommonSubscriptionDataBuilderProtocol: AnyObject {
    func build(subId: String, spaceId: String, objectIds: [String], additionalKeys: [BundledRelationKey]) -> SubscriptionData
}

final class ObjectsCommonSubscriptionDataBuilder: ObjectsCommonSubscriptionDataBuilderProtocol {
    
    // MARK: - ObjectsCommonSubscriptionDataBuilderProtocol
    
    func build(subId: String, spaceId: String, objectIds: [String], additionalKeys: [BundledRelationKey]) -> SubscriptionData {
        return .objects(
            SubscriptionData.Object(
                identifier: subId,
                spaceId: spaceId,
                objectIds: objectIds,
                keys: (BundledRelationKey.objectListKeys + additionalKeys).uniqued().map { $0.rawValue }
            )
        )
    }
}
