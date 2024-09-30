import Foundation
import Services
import AnytypeCore
import Combine

enum RelationDetailsStorageError: Error {
    case relationNotFound
}

private struct RelationDetailsKey: Hashable {
    let key: String
    let spaceId: String
}

final class RelationDetailsStorage: RelationDetailsStorageProtocol {
    
    private enum Constants {
        static let subscriptionIdPrefix = "SubscriptionId.Relation-"
    }
    
    // MARK: - DI
    
    @Injected(\.subscriptionStorageProvider)
    private var subscriptionStorageProvider: any SubscriptionStorageProviderProtocol
    @Injected(\.relationSubscriptionDataBuilder)
    private var subscriptionDataBuilder: any RelationSubscriptionDataBuilderProtocol
    @Injected(\.workspaceStorage)
    private var workspacessStorage: any WorkspacesStorageProtocol
    
    // MARK: - Private properties
    
    private var relations = SynchronizedDictionary<String, [RelationDetails]>()
    private var searchDetailsByKey = SynchronizedDictionary<RelationDetailsKey, RelationDetails>()
    private var subscriptionStorages = SynchronizedDictionary<String, any SubscriptionStorageProtocol>()
    private var spacesSubscription: AnyCancellable?
    
    @Published var sync: () = ()
    var syncPublisher: AnyPublisher<Void, Never> { $sync.eraseToAnyPublisher() }
    
    // MARK: - RelationDetailsStorageProtocol
    
    func relationsDetails(for links: [RelationLink], spaceId: String) -> [RelationDetails] {
        return links.map { searchDetailsByKey[RelationDetailsKey(key: $0.key, spaceId: spaceId)] ?? createDeletedRelation(link: $0) }
    }
    
    func relationsDetails(for ids: [ObjectId], spaceId: String) -> [RelationDetails] {
        return ids.compactMap { id in
            return relationsDetails(spaceId: spaceId).first { $0.id == id && $0.spaceId == spaceId }
        }
    }
    
    func relationsDetails(spaceId: String) -> [RelationDetails] {
        return relations[spaceId] ?? []
    }
    
    func relationsDetails(for key: BundledRelationKey, spaceId: String) throws -> RelationDetails {
        guard let details = searchDetailsByKey[RelationDetailsKey(key: key.rawValue, spaceId: spaceId)] else {
            throw RelationDetailsStorageError.relationNotFound
        }
        return details
    }
    
    func relationsDetails(for key: String, spaceId: String) throws -> RelationDetails {
        guard let details = searchDetailsByKey[RelationDetailsKey(key: key, spaceId: spaceId)] else {
            throw RelationDetailsStorageError.relationNotFound
        }
        return details
    }
    
    func startSubscription() async {
        // Start first subscription in current async context for guarantee data state before return
        let spaceIds = await workspacessStorage.allWorkspaces.map { $0.targetSpaceId }
        await updateSubscriptions(spaceIds: spaceIds)
        
        spacesSubscription = await workspacessStorage.allWorkspsacesPublisher
            .map { $0.map { $0.targetSpaceId } }
            .removeDuplicates()
            .sink { [weak self] spaceIds in
                Task {
                    await self?.updateSubscriptions(spaceIds: spaceIds)
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
        relations.removeAll()
        updateSearchCache()
        sync = ()
    }
    
    // MARK: - Private
    
    private func updateaData(data: SubscriptionStorageState, spaceId: String) {
        relations[spaceId] = data.items.map { RelationDetails(objectDetails: $0) }
        updateSearchCache()
        sync = ()
    }
    
    private func updateSearchCache() {
        searchDetailsByKey.removeAll()
        let values = relations.values.flatMap { $0 }
        values.forEach {
            let key = RelationDetailsKey(key: $0.key, spaceId: $0.spaceId)
            if searchDetailsByKey[key] != nil {
                anytypeAssertionFailure("Dublicate relation found", info: ["key": $0.key, "id": $0.id, "spaceId": $0.spaceId])
            }
            searchDetailsByKey[key] = $0
        }
    }
    
    private func createDeletedRelation(link: RelationLink) -> RelationDetails {
        return RelationDetails(
            id: "",
            key: link.key,
            name: "",
            format: .shortText,
            isHidden: false,
            isReadOnly: true,
            isReadOnlyValue: true,
            objectTypes: [],
            maxCount: 1,
            sourceObject: "",
            isDeleted: true,
            spaceId: ""
        )
    }
    
    private func updateSubscriptions(spaceIds: [String]) async {
        for spaceId in spaceIds {
            if subscriptionStorages[spaceId].isNil {
                let subId = Constants.subscriptionIdPrefix + spaceId
                let subscriptionStorage = subscriptionStorageProvider.createSubscriptionStorage(subId: subId)
                subscriptionStorages[spaceId] = subscriptionStorage
                try? await subscriptionStorage.startOrUpdateSubscription(data: subscriptionDataBuilder.build(spaceId: spaceId, subId: subId)) { [weak self] data in
                    self?.updateaData(data: data, spaceId: spaceId)
                }
            }
        }
    }
}
