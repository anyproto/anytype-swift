import Foundation
import AnytypeCore
import Combine
import Services

protocol MultispaceSubscriptionDataBuilderProtocol: AnyObject, Sendable {
    func build(accountId: String, spaceId: String, subId: String) -> SubscriptionData
}

final class MultispaceSubscriptionHelper<Value: DetailsModel & Sendable>: Sendable {

    // MARK: - DI
    
    private let subIdPrefix: String
    private let subscriptionBuilder: any MultispaceSubscriptionDataBuilderProtocol
    
    private let workspacessStorage: any SpaceViewsStorageProtocol = Container.shared.spaceViewsStorage()
    private let subscriptionStorageProvider: any SubscriptionStorageProviderProtocol = Container.shared.subscriptionStorageProvider()
    private let accountManager: any AccountManagerProtocol = Container.shared.accountManager()
    
    // MARK: - State
    
    let data = SynchronizedDictionary<String, [Value]>()
    
    private let subscriptionStorages = SynchronizedDictionary<String, any SubscriptionStorageProtocol>()
    private let spacesSubscription = AtomicStorage<AnyCancellable?>(nil)
    
    init(subIdPrefix: String, subscriptionBuilder: any MultispaceSubscriptionDataBuilderProtocol) {
        self.subIdPrefix = subIdPrefix
        self.subscriptionBuilder = subscriptionBuilder
    }
    
    func startSubscription(update: @escaping @Sendable () -> Void) async {
        // Start first subscription in current async context for guarantee data state before return
        let spaceIds = workspacessStorage.allSpaceViews
            .filter { $0.isActive || $0.isLoading }
            .map { $0.targetSpaceId }
        await updateSubscriptions(spaceIds: spaceIds, update: update)
        
        spacesSubscription.value = workspacessStorage.allSpaceViewsPublisher
            .map { $0.filter { $0.isActive || $0.isLoading }.map { $0.targetSpaceId } }
            .removeDuplicates()
            .receiveOnMain()
            .sink { [weak self] spaceIds in
                Task { @Sendable [weak self] in
                    await self?.updateSubscriptions(spaceIds: spaceIds, update: update)
                }
            }
    }
    
    func stopSubscription() async {
        spacesSubscription.value?.cancel()
        spacesSubscription.value = nil
        for subscriptionStorage in subscriptionStorages.values {
            try? await subscriptionStorage.stopSubscription()
        }
        subscriptionStorages.removeAll()
        data.removeAll()
    }
    
    private func updateSubscriptions(spaceIds: [String], update: @escaping (@Sendable () -> Void)) async {
        for spaceId in spaceIds {
            if subscriptionStorages[spaceId].isNil {
                let subId = subIdPrefix + spaceId
                let subscriptionStorage = subscriptionStorageProvider.createSubscriptionStorage(subId: subId)
                subscriptionStorages[spaceId] = subscriptionStorage
                try? await subscriptionStorage.startOrUpdateSubscription(
                    data: subscriptionBuilder.build(accountId: accountManager.account.id, spaceId: spaceId, subId: subId)
                ) { [weak self] data in
                    self?.updateStorage(subscriptionState: data, spaceId: spaceId, update: update)
                }
            }
        }
    }
    
    private func updateStorage(subscriptionState: SubscriptionStorageState, spaceId: String, update: (() -> Void)) {
        data[spaceId] = subscriptionState.items.compactMap { try? Value(details: $0) }
        update()
    }
}
