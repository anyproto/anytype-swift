import Foundation
import AnytypeCore
import Combine
import Services

protocol MultispaceSubscriptionDataBuilderProtocol: AnyObject {
    func build(accountId: String, spaceId: String, subId: String) -> SubscriptionData
}

final class MultispaceSubscriptionHelper<Value: DetailsModel> {

    // MARK: - DI
    
    private let subIdPrefix: String
    private let subscriptionBuilder: any MultispaceSubscriptionDataBuilderProtocol
    
    @Injected(\.workspaceStorage)
    private var workspacessStorage: any WorkspacesStorageProtocol
    @Injected(\.subscriptionStorageProvider)
    private var subscriptionStorageProvider: any SubscriptionStorageProviderProtocol
    @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    
    // MARK: - State
    
    private(set) var data = SynchronizedDictionary<String, [Value]>()
    
    private var subscriptionStorages = SynchronizedDictionary<String, any SubscriptionStorageProtocol>()
    private var spacesSubscription: AnyCancellable?
    
    init(subIdPrefix: String, subscriptionBuilder: any MultispaceSubscriptionDataBuilderProtocol) {
        self.subIdPrefix = subIdPrefix
        self.subscriptionBuilder = subscriptionBuilder
    }
    
    func startSubscription(update: @escaping () -> Void) async {
        // Start first subscription in current async context for guarantee data state before return
        let spaceIds = await workspacessStorage.allWorkspaces
            .filter { $0.accountStatus != .spaceRemoving }
            .map { $0.targetSpaceId }
        await updateSubscriptions(spaceIds: spaceIds, update: update)
        
        spacesSubscription = await workspacessStorage.allWorkspsacesPublisher
            .map { $0.filter { $0.accountStatus != .spaceRemoving }.map { $0.targetSpaceId } }
            .removeDuplicates()
            .sink { [weak self] spaceIds in
                Task {
                    await self?.updateSubscriptions(spaceIds: spaceIds, update: update)
                }
            }
    }
    
    func stopSubscription() async {
        spacesSubscription?.cancel()
        spacesSubscription = nil
        for subscriptionStorage in subscriptionStorages.values {
            try? await subscriptionStorage.stopSubscription()
        }
        subscriptionStorages.removeAll()
        data.removeAll()
    }
    
    private func updateSubscriptions(spaceIds: [String], update: @escaping (() -> Void)) async {
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
