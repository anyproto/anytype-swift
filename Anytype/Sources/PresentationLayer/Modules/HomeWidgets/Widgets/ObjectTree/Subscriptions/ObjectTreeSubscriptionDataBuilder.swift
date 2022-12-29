import Foundation
import BlocksModels

protocol ObjectTreeSubscriptionDataBuilderProtocol {
    func build(objectIds: [String]) -> SubscriptionData
}

final class ObjectTreeSubscriptionDataBuilder: ObjectTreeSubscriptionDataBuilderProtocol {
    
    private let builderId = UUID()
    
    // MARK: - ObjectTreeSubscriptionDataBuilderProtocol
    
    func build(objectIds: [String]) -> SubscriptionData {
        let keys = [
            BundledRelationKey.id.rawValue,
            BundledRelationKey.name.rawValue,
            BundledRelationKey.snippet.rawValue,
            BundledRelationKey.links.rawValue,
            BundledRelationKey.type.rawValue,
            BundledRelationKey.layout.rawValue,
            BundledRelationKey.isDeleted.rawValue,
            BundledRelationKey.isArchived.rawValue,
        ]
        
        return .objects(
            SubscriptionData.Object(
                identifier: SubscriptionId(value: "Tree-\(builderId.uuidString)"),
                objectIds: objectIds,
                keys: keys
            )
        )
    }
}
