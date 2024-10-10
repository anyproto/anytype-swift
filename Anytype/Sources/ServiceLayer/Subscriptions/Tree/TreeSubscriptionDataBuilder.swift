import Foundation
import Services

protocol TreeSubscriptionDataBuilderProtocol {
    var subscriptionId: String { get }
    func build(spaceId: String, objectIds: [String]) -> SubscriptionData
}

final class TreeSubscriptionDataBuilder: TreeSubscriptionDataBuilderProtocol {
    
    let subscriptionId = "Tree-\(UUID().uuidString)"
    
    // MARK: - TreeSubscriptionDataBuilderProtocol
    
    func build(spaceId: String, objectIds: [String]) -> SubscriptionData {
        let keys: [BundledRelationKey] = .builder {
            BundledRelationKey.objectListKeys
            BundledRelationKey.links
        }.uniqued()
        
        return .objects(
            SubscriptionData.Object(
                identifier: subscriptionId,
                spaceId: spaceId,
                objectIds: objectIds,
                keys: keys.map { $0.rawValue }
            )
        )
    }
}
