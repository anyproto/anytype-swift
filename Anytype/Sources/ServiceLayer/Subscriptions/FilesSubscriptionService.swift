import Foundation
import Services
import Combine
import AnytypeCore

@MainActor
protocol FilesSubscriptionServiceProtocol: AnyObject {
    func startSubscription(
        syncStatus: FileSyncStatus,
        spaceId: String,
        objectLimit: Int?,
        update: @escaping @MainActor ([ObjectDetails]) -> Void
    ) async
    func stopSubscription() async
}

@MainActor
final class FilesSubscriptionService: FilesSubscriptionServiceProtocol {
    
    private enum Constants {
        static let limit = 100
    }
    
    @Injected(\.subscriptionStorageProvider)
    private var subscriptionStorageProvider: any SubscriptionStorageProviderProtocol
    private lazy var subscriptionStorage: any SubscriptionStorageProtocol = {
        subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionId)
    }()
    private let subscriptionId = "Files-\(UUID().uuidString)"
    
    nonisolated init() {}
    
    // MARK: - FilesSubscriptionServiceProtocol
    
    func startSubscription(
        syncStatus: FileSyncStatus,
        spaceId: String,
        objectLimit: Int?,
        update: @escaping @MainActor ([ObjectDetails]) -> Void
    ) async {
        
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.sizeInBytes,
            type: .desc
        )
        
        let filters: [DataviewFilter] = .builder {
            SearchHelper.notHiddenFilters(hideHiddenDescoveryFiles: false)
            SearchHelper.fileSyncStatus(syncStatus)
        }
        
        let searchData: SubscriptionData = .search(
            SubscriptionData.Search(
                identifier: subscriptionId,
                spaceId: spaceId,
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
            await update(data.items)
        }
    }
    
    func stopSubscription() async {
        try? await subscriptionStorage.stopSubscription()
    }
}
