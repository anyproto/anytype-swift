import Foundation
import Services
import Combine
import AnytypeCore

@MainActor
protocol SpaceManagerSpacesSubscriptionServiceProtocol: AnyObject {
    func startSubscription(update: @escaping ([SpaceView]) -> Void) async
    func stopSubscription() async
}

@MainActor
final class SpaceManagerSpacesSubscriptionService: SpaceManagerSpacesSubscriptionServiceProtocol {
    
    @Injected(\.subscriptionStorageProvider)
    private var subscriptionStorageProvider: SubscriptionStorageProviderProtocol
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: ObjectTypeProviderProtocol
    @Injected(\.activeWorkspaceStorage)
    private var activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    
    private lazy var subscriptionStorage: SubscriptionStorageProtocol = {
        subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionId)
    }()
    private let subscriptionId = "AllSpaces-\(UUID().uuidString)"
    
    nonisolated init() {}
    
    func startSubscription(update: @escaping ([SpaceView]) -> Void) async {
        
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastOpenedDate,
            type: .desc
        )
        
        let filters = [
            SearchHelper.layoutFilter([.spaceView]),
            SearchHelper.isArchivedFilter(isArchived: false),
            SearchHelper.isDeletedFilter(isDeleted: false),
            SearchHelper.spaceAccountStatusExcludeFilter(.spaceDeleted)
        ]
        
        let subscriptionData = SubscriptionData.search(
            SubscriptionData.Search(
                identifier: subscriptionId,
                sorts: [sort],
                filters: filters,
                limit: 0,
                offset: 0,
                keys: SpaceView.subscriptionKeys.map(\.rawValue)
            )
        )
        
        try? await subscriptionStorage.startOrUpdateSubscription(data: subscriptionData) { data in
            update(data.items.map { SpaceView(details: $0) })
        }
    }
    
    func stopSubscription() async {
        try? await subscriptionStorage.stopSubscription()
    }
}

extension Container {
    var spaceManagerSpacesSubscriptionService: Factory<SpaceManagerSpacesSubscriptionServiceProtocol> {
        self { SpaceManagerSpacesSubscriptionService() }
    }
}
