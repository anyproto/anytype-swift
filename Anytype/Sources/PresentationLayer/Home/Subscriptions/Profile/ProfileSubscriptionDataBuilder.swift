import Foundation
import BlocksModels

extension SubscriptionId {
    static var profile = SubscriptionId(value: "SubscriptionId.Profile")
}

final class ProfileSubscriptionDataBuilder: ProfileSubscriptionDataBuilderProtocol {
    
    // MARK: - ProfileSubscriptionDataBuilderProtocol
    
    func profile(id: String) -> SubscriptionData {
        
        let keys = [
            BundledRelationKey.id.rawValue,
            BundledRelationKey.name.rawValue,
            BundledRelationKey.iconImage.rawValue
        ]

        return .objects(
            SubscriptionDescriptionObjects(
                identifier: SubscriptionId.profile,
                objectIds: [id],
                keys: keys
            )
        )
    }
}
