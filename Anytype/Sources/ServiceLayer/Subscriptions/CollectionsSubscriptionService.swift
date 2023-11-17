import Foundation
import Services
import Combine
import AnytypeCore

@MainActor
protocol CollectionsSubscriptionServiceProtocol: AnyObject {
    func startSubscription(
        objectLimit: Int?,
        update: @escaping ([ObjectDetails]) -> Void
    ) async
    func stopSubscription() async
}

@MainActor
final class CollectionsSubscriptionService: CollectionsSubscriptionServiceProtocol {
    
    private enum Constants {
        static let limit = 100
    }
    
    private let subscriptionStorage: SubscriptionStorageProtocol
    private let objectTypeProvider: ObjectTypeProviderProtocol
    private let activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    private let subscriptionId = "Collections-\(UUID().uuidString)"
    
    nonisolated init(
        subscriptionStorageProvider: SubscriptionStorageProviderProtocol,
        activeWorkspaceStorage: ActiveWorkpaceStorageProtocol,
        objectTypeProvider: ObjectTypeProviderProtocol
    ) {
        self.subscriptionStorage = subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionId)
        self.activeWorkspaceStorage = activeWorkspaceStorage
        self.objectTypeProvider = objectTypeProvider
    }
    
    func startSubscription(
        objectLimit: Int?,
        update: @escaping ([ObjectDetails]) -> Void
    ) async {
        
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastModifiedDate,
            type: .desc
        )
        
        let filters = [
            SearchHelper.notHiddenFilter(),
            SearchHelper.isArchivedFilter(isArchived: false),
            SearchHelper.spaceId(activeWorkspaceStorage.workspaceInfo.accountSpaceId),
            SearchHelper.layoutFilter([DetailsLayout.collection])
        ]
        
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
