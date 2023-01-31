import Foundation
import BlocksModels
import Combine
import AnytypeCore

protocol SetsSubscriptionServiceProtocol: AnyObject {
    func startSubscription(
        objectLimit: Int?,
        update: @escaping SubscriptionCallback
    )
    func stopSubscription()
}

final class SetsSubscriptionService: SetsSubscriptionServiceProtocol {
    
    private enum Constants {
        static let limit = 100
    }
    
    private let subscriptionService: SubscriptionsServiceProtocol
    private let objectTypeProvider: ObjectTypeProviderProtocol
    private let accountManager: AccountManagerProtocol
    private let subscriptionId = SubscriptionId(value: "Sets-\(UUID().uuidString)")
    
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
            relation: BundledRelationKey.lastModifiedDate,
            type: .desc
        )
        
        let filters = [
            SearchHelper.notHiddenFilter(),
            SearchHelper.isArchivedFilter(isArchived: false),
            SearchHelper.workspaceId(accountManager.account.info.accountSpaceId),
            SearchHelper.typeFilter(typeIds: objectTypeProvider.objectTypes(smartblockTypes: [.set]).map { $0.id }),
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
