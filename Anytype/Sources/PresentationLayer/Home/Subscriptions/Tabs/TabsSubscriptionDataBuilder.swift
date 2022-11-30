import Foundation
import BlocksModels

extension SubscriptionId {
    static var favoritesTab = SubscriptionId(value: "SubscriptionId.FavoritesTab")
    static var recentTab = SubscriptionId(value: "SubscriptionId.RecentTab")
    static var archiveTab = SubscriptionId(value: "SubscriptionId.ArchiveTab")
    static var sharedTab = SubscriptionId(value: "SubscriptionId.SharedTab")
    static var setsTab = SubscriptionId(value: "SubscriptionId.SetsTab")
}

final class TabsSubscriptionDataBuilder: TabsSubscriptionDataBuilderProtocol {
    
    private enum Constants {
        static let limit = 100
    }
    
    private let objectTypeProvider: ObjectTypeProviderProtocol
    private let accountManager: AccountManager
    
    init(
        objectTypeProvider: ObjectTypeProviderProtocol = ObjectTypeProvider.shared,
        accountManager: AccountManager = AccountManager.shared
    ) {
        self.objectTypeProvider = objectTypeProvider
        self.accountManager = accountManager
    }
    
    // MARK: - TabsSubscriptionDataBuilderProtocol
    
    func build(for tab: HomeTabsView.Tab) -> SubscriptionData {
        switch tab {
        case .favourites:
            return favoritesTab()
        case .sets:
            return setsTab()
        case .shared:
            return sharedTab()
        case .recent:
            return recentTab()
        case .bin:
            return archiveTab()
        }
    }
    
    func allIds() -> [SubscriptionId] {
        return [.sharedTab, .setsTab, .archiveTab, .recentTab, .favoritesTab]
    }
    
    // MARK: - Private
    
    private func recentTab() -> SubscriptionData {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastModifiedDate,
            type: .desc
        )
        var filters = buildFilters(
            isArchived: false,
            typeIds: objectTypeProvider.visibleSupportedTypeIds()
        )
        filters.append(SearchHelper.lastOpenedDateNotNilFilter())
        
        return .search(
            SubscriptionData.Search(
                identifier: SubscriptionId.recentTab,
                sorts: [sort],
                filters: filters,
                limit: Constants.limit,
                offset: 0,
                keys: homeDetailsKeys
            )
        )
    }
    
    private func archiveTab() -> SubscriptionData {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastModifiedDate,
            type: .desc
        )
        
        let filters = buildFilters(
            isArchived: true,
            typeIds: objectTypeProvider.visibleSupportedTypeIds()
        )
        
        return .search(
            SubscriptionData.Search(
                identifier: SubscriptionId.archiveTab,
                sorts: [sort],
                filters: filters,
                limit: Constants.limit,
                offset: 0,
                keys: homeDetailsKeys
            )
        )
    }
    
    private func sharedTab() -> SubscriptionData {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastModifiedDate,
            type: .desc
        )
        var filters = buildFilters(isArchived: false, typeIds: objectTypeProvider.supportedTypeIds)
        filters.append(contentsOf: SearchHelper.sharedObjectsFilters())
        
        return .search(
            SubscriptionData.Search(
                identifier: SubscriptionId.sharedTab,
                sorts: [sort],
                filters: filters,
                limit: Constants.limit,
                offset: 0,
                keys: homeDetailsKeys
            )
        )
    }
    
    private func setsTab() -> SubscriptionData {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastModifiedDate,
            type: .desc
        )
        let filters = buildFilters(
            isArchived: false,
            typeIds: objectTypeProvider.objectTypes(smartblockTypes: [.set]).map { $0.id }
        )
        
        return .search(
            SubscriptionData.Search(
                identifier: SubscriptionId.setsTab,
                sorts: [sort],
                filters: filters,
                limit: Constants.limit,
                offset: 0,
                keys: homeDetailsKeys
            )
        )
    }
    
    private func favoritesTab() -> SubscriptionData {
        var filters = buildFilters(isArchived: false, typeIds: objectTypeProvider.visibleSupportedTypeIds())
        filters.append(SearchHelper.isFavoriteFilter(isFavorite: true))
        
        return .search(
            SubscriptionData.Search(
                identifier: SubscriptionId.favoritesTab,
                sorts: [],
                filters: filters,
                limit: Constants.limit,
                offset: 0,
                keys: homeDetailsKeys
            )
        )
    }

    
    private var homeDetailsKeys: [String] {
        let keys: [BundledRelationKey] = [
            .id,
            .iconEmoji,
            .iconImage,
            .name,
            .snippet,
            .description,
            .type,
            .layout,
            .isArchived,
            .isDeleted,
            .done,
            .isFavorite
        ]
        return keys.map { $0.rawValue }
    }
    
    private func buildFilters(isArchived: Bool, typeIds: [String]) -> [DataviewFilter] {
        return [
            SearchHelper.notHiddenFilter(),
            SearchHelper.isArchivedFilter(isArchived: isArchived),
            SearchHelper.typeFilter(typeIds: typeIds),
            SearchHelper.workspaceId(accountManager.account.info.accountSpaceId)
        ]
    }
}
