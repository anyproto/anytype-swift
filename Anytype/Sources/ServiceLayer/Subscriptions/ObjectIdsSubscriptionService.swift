import Foundation
import Services
import Combine
import AnytypeCore

@MainActor
protocol ObjectIdsSubscriptionServiceProtocol: AnyObject {
    func startSubscription(
        spaceId: String,
        objectIds: [String],
        update: @escaping @MainActor ([ObjectDetails]) -> Void
    ) async
    func stopSubscription() async
}

@MainActor
final class ObjectIdsSubscriptionService: ObjectIdsSubscriptionServiceProtocol {
    
    @Injected(\.subscriptionStorageProvider)
    private var subscriptionStorageProvider: any SubscriptionStorageProviderProtocol
    private lazy var subscriptionStorage: any SubscriptionStorageProtocol = {
        subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionId)
    }()
    
    private let subscriptionId = "ObjectIdsSubscriptionService-\(UUID().uuidString)"
    
    nonisolated init() {}
    
    func startSubscription(
        spaceId: String,
        objectIds: [String],
        update: @escaping @MainActor ([ObjectDetails]) -> Void
    ) async {
        
        let searchData: SubscriptionData = .objects(
            SubscriptionData.Object(
                identifier: subscriptionId,
                spaceId: spaceId,
                objectIds: objectIds,
                keys: (BundledRelationKey.objectListKeys).uniqued().map { $0.rawValue }
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
