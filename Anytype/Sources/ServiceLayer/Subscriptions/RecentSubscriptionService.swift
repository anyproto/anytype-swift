import Foundation
import Services
import Combine
import AnytypeCore

@MainActor
protocol RecentSubscriptionServiceProtocol: AnyObject {
    func startSubscription(
        spaceId: String,
        type: RecentWidgetType,
        objectLimit: Int?,
        update: @escaping @MainActor ([ObjectDetails]) -> Void
    ) async
    func stopSubscription() async
}

@MainActor
final class RecentSubscriptionService: RecentSubscriptionServiceProtocol {
    
    private enum Constants {
        static let limit = 100
    }
    
    @Injected(\.workspaceStorage)
    private var workspaceStorage: any WorkspacesStorageProtocol
    @Injected(\.subscriptionStorageProvider)
    private var subscriptionStorageProvider: any SubscriptionStorageProviderProtocol
    private lazy var subscriptionStorage: any SubscriptionStorageProtocol = {
        subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionId)
    }()
    
    nonisolated init() {}
    
    private let subscriptionId = "Recent-\(UUID().uuidString)"
    
    func startSubscription(
        spaceId: String,
        type: RecentWidgetType,
        objectLimit: Int?,
        update: @escaping @MainActor ([ObjectDetails]) -> Void
    ) async {
        
        let sort = makeSort(type: type)
        
        let filters: [DataviewFilter] = .builder {
            SearchHelper.notHiddenFilters()
            SearchHelper.layoutFilter(DetailsLayout.visibleLayouts)
            SearchHelper.templateScheme(include: false)
            makeDateFilter(type: type, spaceId: spaceId)
        }
        
        let keys: [BundledPropertyKey] = .builder {
            BundledPropertyKey.lastOpenedDate
            BundledPropertyKey.lastModifiedDate
            BundledPropertyKey.links
            BundledPropertyKey.objectListKeys
        }
        
        let searchData: SubscriptionData = .search(
            SubscriptionData.Search(
                identifier: subscriptionId,
                spaceId: spaceId,
                sorts: [sort],
                filters: filters,
                limit: objectLimit ?? Constants.limit,
                offset: 0,
                keys: keys.map { $0.rawValue }
            )
        )
        
        try? await subscriptionStorage.startOrUpdateSubscription(data: searchData) { data in
            await update(data.items)
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
                relation: BundledPropertyKey.lastModifiedDate,
                type: .desc
            )
        case .recentOpen:
            return SearchHelper.sort(
                relation: BundledPropertyKey.lastOpenedDate,
                type: .desc
            )
        }
    }
    
    private func makeDateFilter(type: RecentWidgetType, spaceId: String) -> DataviewFilter? {
        switch type {
        case .recentEdit:
            guard let spaceView = workspaceStorage.spaceView(spaceId: spaceId),
                  let createdDate = spaceView.createdDate else { return nil }
            return SearchHelper.lastModifiedDateFrom(createdDate.addingTimeInterval(3))
        case .recentOpen:
            return SearchHelper.lastOpenedDateNotNilFilter()
        }
    }
}
