import Foundation
import BlocksModels

extension RelationDetails: IdProvider {}

final class RelationDetailsStorage: RelationDetailsStorageProtocol {
    
    private let subscriptionsService: SubscriptionsServiceProtocol = ServiceLocator.shared.subscriptionService()
    private var details = [RelationDetails]()
    private var localSubscriptions = [String: [RelationLink]]()
    
    // MARK: - RelationDetailsStorageProtocol
    
    func relationsDetails(for links: [RelationLink]) -> [RelationDetails] {
        let ids = links.map { $0.id }
        return details.filter { ids.contains($0.id) }
    }
    
    func relationsDetails() -> [RelationDetails] {
        return details
    }
    
    func startSubscription() {
        subscriptionsService.startSubscription(data: .relation) { [weak self] subId, update in
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
