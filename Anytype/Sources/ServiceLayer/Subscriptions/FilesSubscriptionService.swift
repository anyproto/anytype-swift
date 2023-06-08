import Foundation
import BlocksModels
import Combine
import AnytypeCore

protocol FilesSubscriptionServiceProtocol: AnyObject {
    func startSubscription(
        objectLimit: Int?,
        update: @escaping SubscriptionCallback
    )
    func stopSubscription()
}

final class FilesSubscriptionService: FilesSubscriptionServiceProtocol {
    
    private enum Constants {
        static let limit = 100
    }
    
    private let subscriptionService: SubscriptionsServiceProtocol
    private let accountManager: AccountManagerProtocol
    private let subscriptionId = SubscriptionId(value: "Files-\(UUID().uuidString)")
    
    init(
        subscriptionService: SubscriptionsServiceProtocol,
        accountManager: AccountManagerProtocol
    ) {
        self.subscriptionService = subscriptionService
        self.accountManager = accountManager
    }
    
    // MARK: - FilesSubscriptionServiceProtocol
    
    func startSubscription(
        objectLimit: Int?,
        update: @escaping SubscriptionCallback
    ) {
        
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.sizeInBytes,
            type: .desc
        )
        
        let filters = [
            SearchHelper.notHiddenFilter(),
            SearchHelper.workspaceId(accountManager.account.info.accountSpaceId),
            SearchHelper.layoutFilter([DetailsLayout.file, DetailsLayout.image])
        ]
        
        let searchData: SubscriptionData = .search(
            SubscriptionData.Search(
                identifier: subscriptionId,
                sorts: [sort],
                filters: filters,
                limit: objectLimit ?? Constants.limit,
                offset: 0,
                keys: .builder {
                    BundledRelationKey.objectListKeys.map { $0.rawValue }
                    BundledRelationKey.sizeInBytes.rawValue
                }
            )
        )
        
        subscriptionService.startSubscription(data: searchData, update: update)
    }
    
    func stopSubscription() {
        subscriptionService.stopAllSubscriptions()
    }
}
