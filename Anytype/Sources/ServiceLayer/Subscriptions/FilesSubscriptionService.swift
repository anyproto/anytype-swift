import Foundation
import Services
import Combine
import AnytypeCore

@MainActor
protocol FilesSubscriptionServiceProtocol: AnyObject {
    func startSubscription(
        syncStatus: FileSyncStatus,
        objectLimit: Int?,
        update: @escaping ([ObjectDetails]) -> Void
    ) async
    func stopSubscription() async
}

@MainActor
final class FilesSubscriptionService: FilesSubscriptionServiceProtocol {
    
    private enum Constants {
        static let limit = 100
    }
    
    private let subscriptionStorage: SubscriptionStorageProtocol
    private let activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    private let subscriptionId = "Files-\(UUID().uuidString)"
    
    nonisolated init(
        subscriptionStorageProvider: SubscriptionStorageProviderProtocol,
        activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    ) {
        self.subscriptionStorage = subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionId)
        self.activeWorkspaceStorage = activeWorkspaceStorage
    }
    
    // MARK: - FilesSubscriptionServiceProtocol
    
    func startSubscription(
        syncStatus: FileSyncStatus,
        objectLimit: Int?,
        update: @escaping ([ObjectDetails]) -> Void
    ) async {
        
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.sizeInBytes,
            type: .desc
        )
        
        let filters = [
            SearchHelper.notHiddenFilter(),
            SearchHelper.isDeletedFilter(isDeleted: false),
            SearchHelper.spaceId(activeWorkspaceStorage.workspaceInfo.accountSpaceId),
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
        
        try? await subscriptionStorage.startOrUpdateSubscription(data: searchData) { data in
            update(data.items)
        }
    }
    
    func stopSubscription() async {
        try? await subscriptionStorage.stopSubscription()
    }
}
