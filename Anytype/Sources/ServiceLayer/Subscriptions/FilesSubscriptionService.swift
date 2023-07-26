import Foundation
import Services
import Combine
import AnytypeCore

protocol FilesSubscriptionServiceProtocol: AnyObject {
    func startSubscription(
        syncStatus: FileSyncStatus,
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
    private let activeSpaceStorage: ActiveSpaceStorageProtocol
    private let subscriptionId = SubscriptionId(value: "Files-\(UUID().uuidString)")
    
    init(
        subscriptionService: SubscriptionsServiceProtocol,
        activeSpaceStorage: ActiveSpaceStorageProtocol
    ) {
        self.subscriptionService = subscriptionService
        self.activeSpaceStorage = activeSpaceStorage
    }
    
    // MARK: - FilesSubscriptionServiceProtocol
    
    func startSubscription(
        syncStatus: FileSyncStatus,
        objectLimit: Int?,
        update: @escaping SubscriptionCallback
    ) {
        
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.sizeInBytes,
            type: .desc
        )
        
        let filters = [
            SearchHelper.notHiddenFilter(),
            SearchHelper.spaceId(activeSpaceStorage.workspaceInfo.accountSpaceId),
            SearchHelper.layoutFilter([DetailsLayout.file, DetailsLayout.image]),
            SearchHelper.fileSyncStatus(syncStatus)
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
