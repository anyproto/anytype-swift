import Foundation
import AnytypeCore
import Combine
import Services

protocol MultispaceSearchDataBuilderProtocol: AnyObject, Sendable {
    func buildSearch(spaceId: String) -> SearchRequest
}

typealias MultispaceOneActiveSubscriptionDataBuilder = MultispaceSubscriptionDataBuilderProtocol & MultispaceSearchDataBuilderProtocol

actor MultispaceOneActiveSubscriptionHelper<Value: DetailsModel>: Sendable {

    // MARK: - DI
    
    private let subIdPrefix: String
    private let subscriptionBuilder: any MultispaceOneActiveSubscriptionDataBuilder
    
    @Injected(\.subscriptionStorageProvider)
    private var subscriptionStorageProvider: any SubscriptionStorageProviderProtocol
    @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    @Injected(\.searchMiddleService)
    private var searchMiddleService: any SearchMiddleServiceProtocol
    
    // MARK: - State
    
    let data = SynchronizedDictionary<String, [Value]>()
    
    private var activeSubscriptionStorage: (any SubscriptionStorageProtocol)?
    private var activeSpaceId: String?
    private var spacesSubscription: AnyCancellable?
    
    init(subIdPrefix: String, subscriptionBuilder: any MultispaceOneActiveSubscriptionDataBuilder) {
        self.subIdPrefix = subIdPrefix
        self.subscriptionBuilder = subscriptionBuilder
    }
    
    func startSubscription(spaceId: String, update: @escaping @Sendable () -> Void) async {
        await updateSubscription(spaceId: spaceId, update: update)
    }
    
    func stopSubscription() async {
        spacesSubscription?.cancel()
        spacesSubscription = nil
        try? await activeSubscriptionStorage?.stopSubscription()
        activeSubscriptionStorage = nil
        activeSpaceId = nil
        data.removeAll()
    }
    
    func prepareData(spaceId: String) async {
        guard activeSpaceId != spaceId else { return }
        let request = subscriptionBuilder.buildSearch(spaceId: spaceId)
        guard let result = try? await searchMiddleService.search(data: request) else { return }
        let items = result.compactMap { try? Value(details: $0) }
        data[spaceId] = items
    }
    
    private func updateSubscription(spaceId: String, update: @escaping (@Sendable () -> Void)) async {
        guard activeSpaceId != spaceId else { return }
        
        try? await activeSubscriptionStorage?.stopSubscription()
        
        let subId = subIdPrefix + spaceId
        let subscriptionStorage = subscriptionStorageProvider.createSubscriptionStorage(subId: subId)
        activeSpaceId = spaceId
        activeSubscriptionStorage = subscriptionStorage
        data.removeAll()
        
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
