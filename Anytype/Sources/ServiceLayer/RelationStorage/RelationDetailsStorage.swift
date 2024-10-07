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
    
    @Injected(\.relationSubscriptionDataBuilder)
    private var subscriptionDataBuilder: any MultispaceSubscriptionDataBuilderProtocol
    
    private lazy var multispaceSubscriptionHelper = MultispaceSubscriptionHelper<RelationDetails>(
        subIdPrefix: Constants.subscriptionIdPrefix,
        subscriptionBuilder: subscriptionDataBuilder
    )
    
    // MARK: - Private properties
    
    private var searchDetailsByKey = SynchronizedDictionary<RelationDetailsKey, RelationDetails>()
    
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
        return multispaceSubscriptionHelper.data[spaceId] ?? []
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
        await multispaceSubscriptionHelper.startSubscription { [weak self] in
            self?.updateSearchCache()
            self?.sync = ()
        }
    }
    
    func stopSubscription() async {
        await multispaceSubscriptionHelper.stopSubscription()
        updateSearchCache()
        sync = ()
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
}
