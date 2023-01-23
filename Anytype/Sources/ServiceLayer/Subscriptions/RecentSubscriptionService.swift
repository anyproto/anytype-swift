import Foundation
import BlocksModels
import Combine
import AnytypeCore

protocol RecentSubscriptionServiceProtocol: AnyObject {
    func startSubscription(
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
    private let accountManager: AccountManager
    private let subscriptionId = SubscriptionId(value: "Recent-\(UUID().uuidString)")
    
    init(
        subscriptionService: SubscriptionsServiceProtocol,
        accountManager: AccountManager,
        objectTypeProvider: ObjectTypeProviderProtocol
    ) {
        self.subscriptionService = subscriptionService
        self.accountManager = accountManager
        self.objectTypeProvider = objectTypeProvider
    }
    
    func startSubscription(
        objectLimit: Int?,
        update: @escaping SubscriptionCallback
    ) {
        
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastModifiedDate,
            type: .desc
        )
        
        let filters = [
            SearchHelper.notHiddenFilter(),
            SearchHelper.isArchivedFilter(isArchived: false),
            SearchHelper.workspaceId(accountManager.account.info.accountSpaceId),
            SearchHelper.excludedTypeFilter(objectTypeProvider.notVisibleTypeIds()),
            SearchHelper.lastOpenedDateNotNilFilter()
            
        ]
        
        let searchData: SubscriptionData = .search(
            SubscriptionData.Search(
                identifier: subscriptionId,
                sorts: [sort],
                filters: filters,
                limit: objectLimit ?? Constants.limit,
                offset: 0,
                keys: BundledRelationKey.objectListKeys
            )
        )
        
        subscriptionService.startSubscription(data: searchData, update: update)
    }
    
    func stopSubscription() {
        subscriptionService.stopAllSubscriptions()
    }
}
