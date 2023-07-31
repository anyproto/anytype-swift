import Foundation
import Services

protocol TreeSubscriptionDataBuilderProtocol {
    func build(objectIds: [String]) -> SubscriptionData
}

final class TreeSubscriptionDataBuilder: TreeSubscriptionDataBuilderProtocol {
    
    private let subscriptionId = "Tree-\(UUID().uuidString)"
    
    // MARK: - TreeSubscriptionDataBuilderProtocol
    
    func build(objectIds: [String]) -> SubscriptionData {
        let keys: [BundledRelationKey] = .builder {
            BundledRelationKey.objectListKeys
            BundledRelationKey.links
        }.uniqued()
        
        return .objects(
            SubscriptionData.Object(
                identifier: subscriptionId,
                objectIds: objectIds,
                keys: keys.map { $0.rawValue }
            )
        )
    }
}
