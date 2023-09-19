import Foundation
import Services
import Combine
import AnytypeCore

protocol RecentSubscriptionServiceProtocol: AnyObject {
    func startSubscription(
        type: RecentWidgetType,
        objectLimit: Int?,
        update: @escaping SubscriptionCallback
    )
    func stopSubscription()
}

final class RecentSubscriptionService: RecentSubscriptionServiceProtocol {
    
    private enum Constants {
        static let limit = 100
    }
    
    private let subscriptionService: SubscriptionsServiceProtocol
    private let objectTypeProvider: ObjectTypeProviderProtocol
    private let accountManager: AccountManagerProtocol
    private let subscriptionId = "Recent-\(UUID().uuidString)"
    
    init(
        subscriptionService: SubscriptionsServiceProtocol,
        accountManager: AccountManagerProtocol,
        objectTypeProvider: ObjectTypeProviderProtocol
    ) {
        self.subscriptionService = subscriptionService
        self.accountManager = accountManager
        self.objectTypeProvider = objectTypeProvider
    }
    
    func startSubscription(
        type: RecentWidgetType,
        objectLimit: Int?,
        update: @escaping SubscriptionCallback
    ) {
        
        let sort = makeSort(type: type)
        
        let filters: [DataviewFilter] = .builder {
            SearchHelper.notHiddenFilter()
            SearchHelper.isArchivedFilter(isArchived: false)
            SearchHelper.workspaceId(accountManager.account.info.accountSpaceId)
            SearchHelper.layoutFilter(DetailsLayout.visibleLayouts)
            makeDateFilter(type: type)
        }
        
        let keys: [BundledRelationKey] = .builder {
            BundledRelationKey.lastOpenedDate
            BundledRelationKey.lastModifiedDate
            BundledRelationKey.links
            BundledRelationKey.objectListKeys
        }
        
        let searchData: SubscriptionData = .search(
            SubscriptionData.Search(
                identifier: subscriptionId,
                sorts: [sort],
                filters: filters,
                limit: objectLimit ?? Constants.limit,
                offset: 0,
                keys: keys.map { $0.rawValue }
            )
        )
        
        subscriptionService.startSubscription(data: searchData, update: update)
    }
    
    func stopSubscription() {
        subscriptionService.stopAllSubscriptions()
    }
    
    // MARK: - Private
    
    private func makeSort(type: RecentWidgetType) -> DataviewSort {
        switch type {
        case .recentEdit:
            return SearchHelper.sort(
                relation: BundledRelationKey.lastModifiedDate,
                type: .desc
            )
        case .recentOpen:
            return SearchHelper.sort(
                relation: BundledRelationKey.lastOpenedDate,
                type: .desc
            )
        }
    }
    
    private func makeDateFilter(type: RecentWidgetType) -> DataviewFilter? {
        switch type {
        case .recentEdit:
            return nil
        case .recentOpen:
            return SearchHelper.lastOpenedDateNotNilFilter()
        }
    }
}
