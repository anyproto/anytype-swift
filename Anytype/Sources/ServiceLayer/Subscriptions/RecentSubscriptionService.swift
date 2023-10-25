import Foundation
import Services
import Combine
import AnytypeCore

protocol RecentSubscriptionServiceProtocol: AnyObject {
    func startSubscription(
        type: RecentWidgetType,
        objectLimit: Int?,
        update: @escaping ([ObjectDetails]) -> Void
    ) async
    func stopSubscription() async
}

final class RecentSubscriptionService: RecentSubscriptionServiceProtocol {
    
    private enum Constants {
        static let limit = 100
    }
    
    private let subscriptionStorage: SubscriptionStorageProtocol
    private let objectTypeProvider: ObjectTypeProviderProtocol
    private let activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    private let workspacesStorage: WorkspacesStorageProtocol
    private let subscriptionId = "Recent-\(UUID().uuidString)"
    
    init(
        subscriptionStorageProvider: SubscriptionStorageProviderProtocol,
        activeWorkspaceStorage: ActiveWorkpaceStorageProtocol,
        objectTypeProvider: ObjectTypeProviderProtocol,
        workspacesStorage: WorkspacesStorageProtocol
    ) {
        self.subscriptionStorage = subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionId)
        self.activeWorkspaceStorage = activeWorkspaceStorage
        self.objectTypeProvider = objectTypeProvider
        self.workspacesStorage = workspacesStorage
    }
    
    func startSubscription(
        type: RecentWidgetType,
        objectLimit: Int?,
        update: @escaping ([ObjectDetails]) -> Void
    ) async {
        
        let sort = makeSort(type: type)
        
        let filters: [DataviewFilter] = .builder {
            SearchHelper.notHiddenFilter()
            SearchHelper.isArchivedFilter(isArchived: false)
            SearchHelper.spaceId(activeWorkspaceStorage.workspaceInfo.accountSpaceId)
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
        
        try? await subscriptionStorage.startOrUpdateSubscription(data: searchData) { data in
            update(data.items)
        }
    }
    
    func stopSubscription() async {
        try? await subscriptionStorage.stopSubscription()
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
            guard let spaceView = workspacesStorage.workspaces.first(where: { $0.id == activeWorkspaceStorage.workspaceInfo.spaceViewId }),
                  let createdDate = spaceView.createdDate else { return nil }
            return SearchHelper.lastModifiedDateFrom(createdDate.addingTimeInterval(60))
        case .recentOpen:
            return SearchHelper.lastOpenedDateNotNilFilter()
        }
    }
}
