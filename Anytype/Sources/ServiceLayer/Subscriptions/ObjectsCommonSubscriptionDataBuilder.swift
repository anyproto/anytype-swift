import Foundation
import Services

protocol ObjectsCommonSubscriptionDataBuilderProtocol: AnyObject {
    func build(subId: String, spaceId: String, objectIds: [String], additionalKeys: [BundledPropertyKey]) -> SubscriptionData
}

final class ObjectsCommonSubscriptionDataBuilder: ObjectsCommonSubscriptionDataBuilderProtocol {
    
    // MARK: - ObjectsCommonSubscriptionDataBuilderProtocol
    
    func build(subId: String, spaceId: String, objectIds: [String], additionalKeys: [BundledPropertyKey]) -> SubscriptionData {
        return .objects(
            SubscriptionData.Object(
                identifier: subId,
                spaceId: spaceId,
                objectIds: objectIds,
                keys: (BundledPropertyKey.objectListKeys + additionalKeys).uniqued().map { $0.rawValue }
            )
        )
    }
}
