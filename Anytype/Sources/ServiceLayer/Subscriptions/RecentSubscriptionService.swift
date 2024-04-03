import Foundation
import Services
import Combine
import AnytypeCore

@MainActor
protocol RecentSubscriptionServiceProtocol: AnyObject {
    func startSubscription(
        type: RecentWidgetType,
        objectLimit: Int?,
        update: @escaping ([ObjectDetails]) -> Void
    ) async
    func stopSubscription() async
}

@MainActor
final class RecentSubscriptionService: RecentSubscriptionServiceProtocol {
    
    private enum Constants {
        static let limit = 100
    }
    
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: ObjectTypeProviderProtocol
    @Injected(\.activeWorkspaceStorage)
    private var activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    @Injected(\.subscriptionStorageProvider)
    private var subscriptionStorageProvider: SubscriptionStorageProviderProtocol
    private lazy var subscriptionStorage: SubscriptionStorageProtocol = {
        subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionId)
    }()
    
    nonisolated init() {}
    
    private let subscriptionId = "Recent-\(UUID().uuidString)"
    
    func startSubscription(
        type: RecentWidgetType,
        objectLimit: Int?,
        update: @escaping ([ObjectDetails]) -> Void
    ) async {
        
        let sort = makeSort(type: type)
        
        let filters: [DataviewFilter] = .builder {
            SearchHelper.notHiddenFilters()
            SearchHelper.spaceId(activeWorkspaceStorage.workspaceInfo.accountSpaceId)
            SearchHelper.layoutFilter(DetailsLayout.visibleLayouts)
            SearchHelper.templateScheme(include: false)
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
            guard let spaceView = activeWorkspaceStorage.spaceView(),
                  let createdDate = spaceView.createdDate else { return nil }
            return SearchHelper.lastModifiedDateFrom(createdDate.addingTimeInterval(3))
        case .recentOpen:
            return SearchHelper.lastOpenedDateNotNilFilter()
        }
    }
}
