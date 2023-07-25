import Foundation
import Services
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
    private let accountManager: AccountManagerProtocol
    private let subscriptionId = SubscriptionId(value: "Recent-\(UUID().uuidString)")
    
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
        objectLimit: Int?,
        update: @escaping SubscriptionCallback
    ) {
        
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastOpenedDate,
            type: .desc
        )
        
        let filters = [
            SearchHelper.notHiddenFilter(),
            SearchHelper.isArchivedFilter(isArchived: false),
            SearchHelper.spaceId(accountManager.account.info.accountSpaceId),
            SearchHelper.layoutFilter(DetailsLayout.visibleLayouts),
            SearchHelper.lastOpenedDateNotNilFilter()
            
        ]
        
        let keys: [BundledRelationKey] = .builder {
            BundledRelationKey.lastOpenedDate
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
}
