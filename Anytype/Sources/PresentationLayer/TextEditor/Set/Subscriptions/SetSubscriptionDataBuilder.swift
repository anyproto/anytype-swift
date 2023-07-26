import Foundation
import Services

extension SubscriptionId {
    static var set = SubscriptionId(value: "SubscriptionId.Set")
    static var setGroups = SubscriptionId(value: "SubscriptionId.Set.Groups")
}

final class SetSubscriptionDataBuilder: SetSubscriptionDataBuilderProtocol {
    
    private let activeSpaceStorage: ActiveSpaceStorageProtocol
    
    init(activeSpaceStorage: ActiveSpaceStorageProtocol) {
        self.activeSpaceStorage = activeSpaceStorage
    }
    
    // MARK: - SetSubscriptionDataBuilderProtocol
    
    func set(_ data: SetSubsriptionData) -> SubscriptionData {
        let numberOfRowsPerPageInSubscriptions = data.numberOfRowsPerPage

        let keys = buildKeys(with: data)
        
        let offset = (data.currentPage - 1) * numberOfRowsPerPageInSubscriptions
        
        let defaultFilters = [
            SearchHelper.spaceId(activeSpaceStorage.workspaceInfo.accountSpaceId)
        ]
        
        let filters = data.filters + defaultFilters
        
        return .search(
            SubscriptionData.Search(
                identifier: data.identifier,
                sorts: data.sorts,
                filters: filters,
                limit: numberOfRowsPerPageInSubscriptions,
                offset: offset,
                keys: keys,
                source: data.source,
                collectionId: data.collectionId
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
            BundledRelationKey.coverY.rawValue,
            BundledRelationKey.relationOptionColor.rawValue
        ]
        
        keys.append(contentsOf: data.options.map { $0.key })
        keys.append(data.coverRelationKey)
        
        return keys
    }
}
