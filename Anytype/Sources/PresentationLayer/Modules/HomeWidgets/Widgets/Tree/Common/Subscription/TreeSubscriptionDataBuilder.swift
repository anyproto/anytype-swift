import Foundation
import BlocksModels

protocol TreeSubscriptionDataBuilderProtocol {
    func build(objectIds: [String]) -> SubscriptionData
}

final class TreeSubscriptionDataBuilder: TreeSubscriptionDataBuilderProtocol {
    
    private let builderId = UUID()
    
    // MARK: - TreeSubscriptionDataBuilderProtocol
    
    func build(objectIds: [String]) -> SubscriptionData {
        let keys: [BundledRelationKey] = .builder {
            BundledRelationKey.objectListKeys
            BundledRelationKey.links
        }.uniqued()
        
        return .objects(
            SubscriptionData.Object(
                identifier: SubscriptionId(value: "Tree-\(builderId.uuidString)"),
                objectIds: objectIds,
                keys: keys.map { $0.rawValue }
            )
        )
    }
}
