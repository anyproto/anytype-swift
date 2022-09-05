import Foundation
import BlocksModels

extension RelationDetails: IdProvider {}

final class RelationDetailsStorage {
    
    public static let shared = RelationDetailsStorage()
    
    private let subscriptionsService: SubscriptionsServiceProtocol = ServiceLocator.shared.subscriptionService()
    private var details = [RelationDetails]()
    private var localSubscriptions = [String: [RelationLink]]()
    
    private init() {
        self.startSubscription()
    }
    
    func relations(for links: [RelationLink]) -> [RelationDetails] {
        let ids = links.map { $0.id }
        return details.filter { ids.contains($0.id) }
    }
    
    func relations() -> [RelationDetails] {
        return details
    }
    
    func subscribeForLocalEvents(contextId: String, links: [RelationLink]) {
        localSubscriptions[contextId] = links
    }
    
    func unsubscribeFromLocalEvents(contextId: String) {
        localSubscriptions.removeValue(forKey: contextId)
    }
    
    private func startSubscription() {
        subscriptionsService.startSubscription(data: .relation) { [weak self] subId, update in
            self?.handleEvent(update: update)
        }
    }
    
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
        for (objectId, relationLinks) in localSubscriptions {
            let ids = relationLinks.filter { relationIds.contains($0.id) }.map { $0.id }
            if ids.isNotEmpty {
                EventsBunch(contextId: objectId, localEvents: [.relationChanged(relationIds: ids)])
                    .send()
            }
        }
    }
}
