import Foundation
import Services
import AnytypeCore
import Combine

enum PropertyDetailsStorageError: Error {
    case relationNotFound
}

private struct RelationDetailsKey: Hashable {
    let key: String
    let spaceId: String
}

final class PropertyDetailsStorage: PropertyDetailsStorageProtocol, Sendable {
    
    private enum Constants {
        static let subscriptionIdPrefix = "SubscriptionId.Relation-"
    }
    
    // MARK: - DI
    
    private let subscriptionDataBuilder: any MultispaceSubscriptionDataBuilderProtocol = Container.shared.relationSubscriptionDataBuilder()
    
    private let multispaceSubscriptionHelper : MultispaceOneActiveSubscriptionHelper<RelationDetails>
    
    // MARK: - Private properties
    
    private let searchDetailsByKey = SynchronizedDictionary<RelationDetailsKey, RelationDetails>()
    
    private let sync = AtomicPublishedStorage<Void>(())
    var syncPublisher: AnyPublisher<Void, Never> { sync.publisher.eraseToAnyPublisher() }
    
    init() {
        multispaceSubscriptionHelper = MultispaceOneActiveSubscriptionHelper<RelationDetails>(
            subIdPrefix: Constants.subscriptionIdPrefix,
            subscriptionBuilder: subscriptionDataBuilder
        )
    }
    
    // MARK: - PropertyDetailsStorageProtocol
    
    func relationsDetails(keys: [String], spaceId: String) -> [RelationDetails] {
        return keys.map { searchDetailsByKey[RelationDetailsKey(key: $0, spaceId: spaceId)] ?? createDeletedRelation(key: $0) }
    }
    
    func relationsDetails(ids: [String], spaceId: String) -> [RelationDetails] {
        return ids.compactMap { id in
            return relationsDetails(spaceId: spaceId).first { $0.id == id && $0.spaceId == spaceId }
        }
    }
    
    func relationsDetails(spaceId: String) -> [RelationDetails] {
        return multispaceSubscriptionHelper.data[spaceId] ?? []
    }
    
    func relationsDetails(bundledKey: BundledRelationKey, spaceId: String) throws -> RelationDetails {
        guard let details = searchDetailsByKey[RelationDetailsKey(key: bundledKey.rawValue, spaceId: spaceId)] else {
            throw PropertyDetailsStorageError.relationNotFound
        }
        return details
    }
    
    func relationsDetails(key: String, spaceId: String) throws -> RelationDetails {
        guard let details = searchDetailsByKey[RelationDetailsKey(key: key, spaceId: spaceId)] else {
            throw PropertyDetailsStorageError.relationNotFound
        }
        return details
    }
    
    func startSubscription(spaceId: String) async {
        await multispaceSubscriptionHelper.startSubscription(spaceId: spaceId) { [weak self] in
            self?.updateSearchCache()
            self?.sync.value = ()
        }
    }
    
    func stopSubscription(cleanCache: Bool) async {
        await multispaceSubscriptionHelper.stopSubscription(cleanCache: cleanCache)
        if cleanCache {
            updateSearchCache()
            sync.value = ()
        }
    }
    
    // MARK: - Private
    
    private func updateSearchCache() {
        searchDetailsByKey.removeAll()
        let values = multispaceSubscriptionHelper.data.values.flatMap { $0 }
        values.forEach {
            let key = RelationDetailsKey(key: $0.key, spaceId: $0.spaceId)
            if searchDetailsByKey[key] != nil {
                anytypeAssertionFailure("Dublicate relation found", info: ["key": $0.key, "id": $0.id, "spaceId": $0.spaceId])
            }
            searchDetailsByKey[key] = $0
        }
    }
    
    private func createDeletedRelation(key: String) -> RelationDetails {
        return RelationDetails(
            id: "",
            key: key,
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
}
