import Foundation
import Services

@MainActor
protocol SimpleSetSubscriptionServiceProtocol: AnyObject {
    func startSubscription(
        setDocument: some SetDocumentProtocol,
        limit: Int,
        update: @escaping @Sendable @MainActor ([ObjectDetails], Int) -> Void
    ) async
    func stopSubscription() async
}

@MainActor
final class SimpleSetSubscriptionService: SimpleSetSubscriptionServiceProtocol {
    
    @Injected(\.subscriptionStorageProvider)
    private var subscriptionStorageProvider: any SubscriptionStorageProviderProtocol
    private lazy var subscriptionStorage: any SubscriptionStorageProtocol = {
        subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionId)
    }()
    @Injected(\.setSubscriptionDataBuilder)
    private var setSubscriptionDataBuilder: any SetSubscriptionDataBuilderProtocol
    
    private let subscriptionId = "SimpleSet-\(UUID().uuidString)"
    
    private var currentSubscriptionData: SubscriptionData? = nil
    
    nonisolated init() {}
    
    func startSubscription(
        setDocument: some SetDocumentProtocol,
        limit: Int,
        update: @escaping @Sendable @MainActor ([ObjectDetails], Int) -> Void
    ) async {
        
        let data = setSubscriptionDataBuilder.set(
            SetSubscriptionData(
                identifier: subscriptionId,
                document: setDocument,
                groupFilter: nil,
                currentPage: 1,
                numberOfRowsPerPage: limit,
                collectionId: nil,
                objectOrderIds: setDocument.objectOrderIds(for: setSubscriptionDataBuilder.subscriptionId)
            )
        )
        
        try? await subscriptionStorage.startOrUpdateSubscription(data: data) { data in
            await update(data.items, data.prevCount)
        }
    }
    
    func stopSubscription() async {
        try? await subscriptionStorage.stopSubscription()
    }
}
