import Foundation
import BlocksModels

extension SubscriptionId {
    static var set = SubscriptionId(value: "SubscriptionId.Set")
}

final class SetSubscriptionDataBuilder: SetSubscriptionDataBuilderProtocol {
    
    // MARK: - SetSubscriptionDataBuilderProtocol
    
    func set(_ data: SetSubsriptionData) -> SubscriptionData {
        let numberOfRowsPerPageInSubscriptions = UserDefaultsConfig.rowsPerPageInSet

        let keys = buildKeys(with: data)
        
        let offset = (data.currentPage - 1) * numberOfRowsPerPageInSubscriptions
        
        return .search(
            SubscriptionData.Search(
                identifier: data.identifier,
                sorts: data.sorts,
                filters: data.filters,
                limit: numberOfRowsPerPageInSubscriptions,
                offset: offset,
                keys: keys,
                source: data.source
            )
        )
    }
    
    
    func buildKeys(with data: SetSubsriptionData) -> [String] {
        
        var keys = [
            BundledRelationKey.id.rawValue,
            BundledRelationKey.iconEmoji.rawValue,
            BundledRelationKey.iconImage.rawValue,
            BundledRelationKey.name.rawValue,
            BundledRelationKey.snippet.rawValue,
            BundledRelationKey.description.rawValue,
            BundledRelationKey.type.rawValue,
            BundledRelationKey.layout.rawValue,
            BundledRelationKey.isDeleted.rawValue,
            BundledRelationKey.done.rawValue,
            BundledRelationKey.coverId.rawValue,
            BundledRelationKey.coverScale.rawValue,
            BundledRelationKey.coverType.rawValue,
            BundledRelationKey.coverX.rawValue,
            BundledRelationKey.coverY.rawValue
        ]
        
        keys.append(contentsOf: data.options.map { $0.key })
        keys.append(data.coverRelationKey)
        
        return keys
    }
}
