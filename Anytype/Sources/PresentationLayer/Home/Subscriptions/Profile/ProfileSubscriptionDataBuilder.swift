import Foundation
import BlocksModels

extension SubscriptionId {
    static var profile = SubscriptionId(value: "SubscriptionId.Profile")
}

final class ProfileSubscriptionDataBuilder: ProfileSubscriptionDataBuilderProtocol {
    
    // MARK: - ProfileSubscriptionDataBuilderProtocol
    
    func profile(id: String) -> SubscriptionData {
        
        let keys: [BundledRelationKey] = .builder {
            BundledRelationKey.id
            BundledRelationKey.objectIconImageKeys
            BundledRelationKey.titleKeys
        }.uniqued()

        return .objects(
            SubscriptionData.Object(
                identifier: SubscriptionId.profile,
                objectIds: [id],
                keys: keys.map { $0.rawValue }
            )
        )
    }
}
