import Foundation
import AnytypeCore
import Combine
import Services

actor MultispaceOneActiveSubscriptionHelper<Value: DetailsModel>: Sendable {

    // MARK: - DI
    
    private let subIdPrefix: String
    private let subscriptionBuilder: any MultispaceSubscriptionDataBuilderProtocol
    
    @Injected(\.subscriptionStorageProvider)
    private var subscriptionStorageProvider: any SubscriptionStorageProviderProtocol
    @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    
    // MARK: - State
    
    let data = SynchronizedDictionary<String, [Value]>()
    
    private var activeSubscriptionStorage: (any SubscriptionStorageProtocol)?
    private var activeSpaceId: String?
    private var spacesSubscription: AnyCancellable?
    
    init(subIdPrefix: String, subscriptionBuilder: any MultispaceSubscriptionDataBuilderProtocol) {
        self.subIdPrefix = subIdPrefix
        self.subscriptionBuilder = subscriptionBuilder
    }
    
    func startSubscription(spaceId: String, update: @escaping @Sendable () -> Void) async {
        await updateSubscription(spaceId: spaceId, update: update)
    }
    
    func stopSubscription(cleanCache: Bool) async {
        spacesSubscription?.cancel()
        spacesSubscription = nil
        try? await activeSubscriptionStorage?.stopSubscription()
        activeSubscriptionStorage = nil
        activeSpaceId = nil
        if cleanCache {
            data.removeAll()
        }
    }
    
    private func updateSubscription(spaceId: String, update: @escaping (@Sendable () -> Void)) async {
        guard activeSpaceId != spaceId else { return }
        
        try? await activeSubscriptionStorage?.stopSubscription()
        
        let subId = subIdPrefix + spaceId
        let subscriptionStorage = subscriptionStorageProvider.createSubscriptionStorage(subId: subId)
        activeSpaceId = spaceId
        activeSubscriptionStorage = subscriptionStorage
        try? await subscriptionStorage.startOrUpdateSubscription(
            data: subscriptionBuilder.build(accountId: accountManager.account.id, spaceId: spaceId, subId: subId)
        ) { [weak self] data in
            await self?.updateStorage(subscriptionState: data, spaceId: spaceId, update: update)
        }
    }
    
    private func updateStorage(subscriptionState: SubscriptionStorageState, spaceId: String, update: (() -> Void)) {
        data[spaceId] = subscriptionState.items.compactMap { try? Value(details: $0) }
        update()
    }
}
