import Foundation
import BlocksModels

extension RelationDetails: IdProvider {}

final class RelationDetailsStorage: RelationDetailsStorageProtocol {
    
    private let subscriptionsService: SubscriptionsServiceProtocol
    private let subscriptionDataBuilder: RelationSubscriptionDataBuilderProtocol
    
    private var details = [RelationDetails]()
    private var localSubscriptions = [String: [RelationLink]]()

    init(
        subscriptionsService: SubscriptionsServiceProtocol,
        subscriptionDataBuilder: RelationSubscriptionDataBuilderProtocol
    ) {
        self.subscriptionsService = subscriptionsService
        self.subscriptionDataBuilder = subscriptionDataBuilder
    }
    // MARK: - RelationDetailsStorageProtocol
    
    func relationsDetails(for links: [RelationLink]) -> [RelationDetails] {
        let keys = links.map { $0.key }
        return details.filter { keys.contains($0.key) }
    }
    
    func relationsDetails() -> [RelationDetails] {
        return details
    }
    
    func startSubscription() {
        subscriptionsService.startSubscription(data: subscriptionDataBuilder.build()) { [weak self] subId, update in
            self?.handleEvent(update: update)
        }
    }
    
    func stopSubscription() {
        subscriptionsService.stopSubscription(id: .relation)
        details.removeAll()
        localSubscriptions.removeAll()
    }
    
    // MARK: - Private
    
    private func handleEvent(update: SubscriptionUpdate) {
        details.applySubscriptionUpdate(update, transform: { RelationDetails(objectDetails: $0) })
        
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
}
