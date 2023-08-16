import Foundation
import Services

protocol ObjectsCommonSubscriptionDataBuilderProtocol: AnyObject {
    func build(subIdPrefix: String, objectIds: [String], additionalKeys: [BundledRelationKey]) -> SubscriptionData
}

final class ObjectsCommonSubscriptionDataBuilder: ObjectsCommonSubscriptionDataBuilderProtocol {
    
    private let idUUID = UUID().uuidString
    
    // MARK: - ObjectsCommonSubscriptionDataBuilderProtocol
    
    func build(subIdPrefix: String, objectIds: [String], additionalKeys: [BundledRelationKey]) -> SubscriptionData {
        return .objects(
            SubscriptionData.Object(
                identifier: "\(subIdPrefix)-\(idUUID)",
                objectIds: objectIds,
                keys: (BundledRelationKey.objectListKeys + additionalKeys).uniqued().map { $0.rawValue }
            )
        )
    }
}
