import Foundation
import BlocksModels

// TODO what?
extension Relation: IdProvider {}

final class RelationStorage: RelationStorageProtocol {
    
    private let subscriptionsService: SubscriptionsServiceProtocol = ServiceLocator.shared.subscriptionService()
    private var details = [Relation]()
    private var localSubscriptions = [String: [RelationLink]]()
    
    init() {
        self.startSubscription()
    }
    
    // MARK: - RelationStorageProtocol
    
    func relations(for links: [RelationLink]) -> [Relation] {
        let ids = links.map { $0.id }
        return details.filter { ids.contains($0.id) }
    }
    
    func relations() -> [Relation] {
        return details
    }
    
    // MARK: - Private
    
    private func startSubscription() {
        subscriptionsService.startSubscription(data: .relation) { [weak self] subId, update in
            self?.handleEvent(update: update)
        }
    }
    
    private func handleEvent(update: SubscriptionUpdate) {
        details.applySubscriptionUpdate(update, transform: { Relation(objectDetails: $0) })
        
        switch update {
        case .initialData(let details):
            let ids = details.map { $0.id }
            sendLocalEvents(relationIds: ids)
        case .update(let objectDetails):
            sendLocalEvents(relationIds: [objectDetails.id])
        case .remove, .add, .move, .pageCount:
            break
        }
    }
    
    private func sendLocalEvents(relationIds: [String]) {
        RelationEventsBunch(events: [.relationChanged(relationIds: relationIds)])
            .send()
    }
}
