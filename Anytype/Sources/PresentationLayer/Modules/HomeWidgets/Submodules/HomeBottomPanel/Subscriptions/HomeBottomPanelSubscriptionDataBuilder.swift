import Foundation
import BlocksModels

protocol HomeBottomPanelSubscriptionDataBuilderProtocol {
    func build(objectId: String) -> SubscriptionData
}

fileprivate extension SubscriptionId {
    static var homeBottom = SubscriptionId(value: "HomeBottomPanelSubscription")
}

final class HomeBottomPanelSubscriptionDataBuilder: HomeBottomPanelSubscriptionDataBuilderProtocol {
    
    // MARK: - HomeBottomPanelSubscriptionDataBuilderProtocol
    
    func build(objectId: String) -> SubscriptionData {
        let keys = [
            BundledRelationKey.id.rawValue,
            BundledRelationKey.name.rawValue,
            BundledRelationKey.snippet.rawValue,
            BundledRelationKey.type.rawValue,
            BundledRelationKey.layout.rawValue,
            BundledRelationKey.iconImage.rawValue,
            BundledRelationKey.iconEmoji.rawValue,
            BundledRelationKey.isDeleted.rawValue,
            BundledRelationKey.done.rawValue
        ]
        
        return .objects(
            SubscriptionData.Object(
                identifier: .homeBottom,
                objectIds: [objectId],
                keys: keys
            )
        )
    }
}
