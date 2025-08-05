import Foundation
import Services
import AnytypeCore
import Combine

enum PropertyDetailsStorageError: Error {
    case relationNotFound
}

private struct PropertyDetailsKey: Hashable {
    let key: String
    let spaceId: String
}

final class PropertyDetailsStorage: PropertyDetailsStorageProtocol, Sendable {
    
    private enum Constants {
        static let subscriptionIdPrefix = "SubscriptionId.Relation-"
    }
    
    // MARK: - DI
    
    private let subscriptionDataBuilder: any MultispaceSubscriptionDataBuilderProtocol = Container.shared.propertySubscriptionDataBuilder()
    
    private let multispaceSubscriptionHelper : MultispaceOneActiveSubscriptionHelper<PropertyDetails>
    
    // MARK: - Private properties
    
    private let searchDetailsByKey = SynchronizedDictionary<PropertyDetailsKey, PropertyDetails>()
    
    private let sync = AtomicPublishedStorage<Void>(())
    var syncPublisher: AnyPublisher<Void, Never> { sync.publisher.eraseToAnyPublisher() }
    
    init() {
        multispaceSubscriptionHelper = MultispaceOneActiveSubscriptionHelper<PropertyDetails>(
            subIdPrefix: Constants.subscriptionIdPrefix,
            subscriptionBuilder: subscriptionDataBuilder
        )
    }
    
    // MARK: - PropertyDetailsStorageProtocol
    
    func relationsDetails(keys: [String], spaceId: String) -> [PropertyDetails] {
        return keys.map { searchDetailsByKey[PropertyDetailsKey(key: $0, spaceId: spaceId)] ?? createDeletedRelation(key: $0) }
    }
    
    func relationsDetails(ids: [String], spaceId: String) -> [PropertyDetails] {
        return ids.compactMap { id in
            return relationsDetails(spaceId: spaceId).first { $0.id == id && $0.spaceId == spaceId }
        }
    }
    
    func relationsDetails(spaceId: String) -> [PropertyDetails] {
        return multispaceSubscriptionHelper.data[spaceId] ?? []
    }
    
    func relationsDetails(bundledKey: BundledPropertyKey, spaceId: String) throws -> PropertyDetails {
        guard let details = searchDetailsByKey[PropertyDetailsKey(key: bundledKey.rawValue, spaceId: spaceId)] else {
            throw PropertyDetailsStorageError.relationNotFound
        }
        return details
    }
    
    func relationsDetails(key: String, spaceId: String) throws -> PropertyDetails {
        guard let details = searchDetailsByKey[PropertyDetailsKey(key: key, spaceId: spaceId)] else {
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
    
    func stopSubscription() async {
        await multispaceSubscriptionHelper.stopSubscription()
        updateSearchCache()
        sync.value = ()
    }
    
    // MARK: - Private
    
    private func updateSearchCache() {
        searchDetailsByKey.removeAll()
        let values = multispaceSubscriptionHelper.data.values.flatMap { $0 }
        values.forEach {
            let key = PropertyDetailsKey(key: $0.key, spaceId: $0.spaceId)
            if searchDetailsByKey[key] != nil {
                anytypeAssertionFailure("Dublicate relation found", info: ["key": $0.key, "id": $0.id, "spaceId": $0.spaceId])
            }
            searchDetailsByKey[key] = $0
        }
    }
    
    private func createDeletedRelation(key: String) -> PropertyDetails {
        return PropertyDetails(
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
