import Foundation
import Services
import Combine
import AnytypeCore

@MainActor
protocol BinSubscriptionServiceProtocol: AnyObject {
    func startSubscription(
        objectLimit: Int?,
        update: @escaping ([ObjectDetails]) -> Void
    ) async
    func stopSubscription() async
}

@MainActor
final class BinSubscriptionService: BinSubscriptionServiceProtocol {
    
    private enum Constants {
        static let limit = 100
    }
    
    @Injected(\.activeWorkspaceStorage)
    private var activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    @Injected(\.subscriptionStorageProvider)
    private var subscriptionStorageProvider: SubscriptionStorageProviderProtocol
    private lazy var subscriptionStorage: SubscriptionStorageProtocol = {
        subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionId)
    }()
    private let subscriptionId = "Bin-\(UUID().uuidString)"
    
    nonisolated init() {}
    
    func startSubscription(
        objectLimit: Int?,
        update: @escaping ([ObjectDetails]) -> Void
    ) async {
        
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastModifiedDate,
            type: .desc
        )
        
        let filters: [DataviewFilter] = .builder {
            SearchHelper.notHiddenFilters(isArchive: true)
            SearchHelper.spaceId(activeWorkspaceStorage.workspaceInfo.accountSpaceId)
        }
        
        let searchData: SubscriptionData = .search(
            SubscriptionData.Search(
                identifier: subscriptionId,
                sorts: [sort],
                filters: filters,
                limit: objectLimit ?? Constants.limit,
                offset: 0,
                keys: BundledRelationKey.objectListKeys.map { $0.rawValue }
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
