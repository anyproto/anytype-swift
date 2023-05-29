import Foundation
import BlocksModels

protocol ObjectsCommonSubscriptionDataBuilderProtocol: AnyObject {
    func build(subIdPrefix: String, objectIds: [String]) -> SubscriptionData
}

final class ObjectsCommonSubscriptionDataBuilder: ObjectsCommonSubscriptionDataBuilderProtocol {
    
    private let idUUID = UUID().uuidString
    
    // MARK: - ObjectsCommonSubscriptionDataBuilderProtocol
    
    func build(subIdPrefix: String, objectIds: [String]) -> SubscriptionData {
        return .objects(
            SubscriptionData.Object(
                identifier: SubscriptionId(value: "\(subIdPrefix)-\(idUUID)"),
                objectIds: objectIds,
                keys: BundledRelationKey.objectListKeys.map { $0.rawValue }
            )
        )
    }
}
