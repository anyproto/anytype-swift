import Foundation
import Services
import AnytypeCore
import Combine

extension RelationDetails: IdProvider {}

enum RelationDetailsStorageError: Error {
    case relationNotFound
}

private struct RelationDetailsKey: Hashable {
    let key: String
    let spaceId: String
}

final class RelationDetailsStorage: RelationDetailsStorageProtocol {
    
    static let subscriptionId = "SubscriptionId.Relation"
    
    private let subscriptionsService: SubscriptionsServiceProtocol
    private let subscriptionDataBuilder: RelationSubscriptionDataBuilderProtocol
    
    private var details = [RelationDetails]()
    private var searchDetailsByKey = SynchronizedDictionary<RelationDetailsKey, RelationDetails>()

    private var relationsDetailsSubject = CurrentValueSubject<[RelationDetails], Never>([])
    var relationsDetailsPublisher: AnyPublisher<[RelationDetails], Never> {
        relationsDetailsSubject.eraseToAnyPublisher()
    }
    
    init(
        subscriptionsService: SubscriptionsServiceProtocol,
        subscriptionDataBuilder: RelationSubscriptionDataBuilderProtocol
    ) {
        self.subscriptionsService = subscriptionsService
        self.subscriptionDataBuilder = subscriptionDataBuilder
    }
    // MARK: - RelationDetailsStorageProtocol
    
    func relationsDetails(for links: [RelationLink], spaceId: String) -> [RelationDetails] {
        return links.map { searchDetailsByKey[RelationDetailsKey(key: $0.key, spaceId: spaceId)] ?? createDeletedRelation(link: $0) }
    }
    
    func relationsDetails(for ids: [ObjectId], spaceId: String) -> [RelationDetails] {
        return ids.compactMap { id in
            return details.first { $0.id == id && $0.spaceId == spaceId }
        }
    }
    
    func relationsDetails(spaceId: String) -> [RelationDetails] {
        return details.filter { $0.spaceId == spaceId }
    }
    
    func relationsDetails(for key: BundledRelationKey, spaceId: String) throws -> RelationDetails {
        guard let details = searchDetailsByKey[RelationDetailsKey(key: key.rawValue, spaceId: spaceId)] else {
            throw RelationDetailsStorageError.relationNotFound
        }
        return details
    }
    
    func startSubscription() async {
        await subscriptionsService.startSubscriptionAsync(data: subscriptionDataBuilder.build()) { [weak self] subId, update in
            self?.handleEvent(update: update)
        }
    }
    
    func stopSubscription() {
        subscriptionsService.stopSubscription(id: Self.subscriptionId)
        details.removeAll()
        updateSearchCache()
        relationsDetailsSubject.send(details)
    }
    
    // MARK: - Private
    
    private func handleEvent(update: SubscriptionUpdate) {
        details.applySubscriptionUpdate(update, transform: { RelationDetails(objectDetails: $0) })
        updateSearchCache()
        relationsDetailsSubject.send(details)
        
        switch update {
        case .initialData(let details):
            let relationKeys = details.map { $0.relationKey }
            sendLocalEvents(relationKeys: relationKeys)
        case .update(let objectDetails):
            sendLocalEvents(relationKeys: [objectDetails.relationKey])
        case .remove, .add, .move, .pageCount:
            break
        }
    }
    
    private func sendLocalEvents(relationKeys: [String]) {
        RelationEventsBunch(events: [.relationChanged(relationKeys: relationKeys)])
            .send()
    }
    
    private func updateSearchCache() {
        searchDetailsByKey.removeAll()
        details.forEach {
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
