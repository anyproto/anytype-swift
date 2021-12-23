import BlocksModels
import Combine
import AnytypeCore


final class SubscriptionsStorage {
    
    public static let shared = SubscriptionsStorage()
    
    @Published var history: [ObjectDetails] = []
    
    private var subscription: AnyCancellable?
    private let service: SubscriptionServiceProtocol = SubscriptionService()
    
    private init() {
        setup()
    }
    
    func toggleHistorySubscription(_ turnOn: Bool) {
        let details = service.toggleHistorySubscription(turnOn) ?? []
        details.forEach { ObjectDetailsStorage.shared.add(details: $0) }
        history = details
    }
    
    // MARK: - Private
    
    private func setup() {
        subscription = NotificationCenter.Publisher(
            center: .default,
            name: .middlewareEvent,
            object: nil
        )
            .compactMap { $0.object as? EventsBunch }
            .filter { $0.objectId == "" }
            .sink { [weak self] events in
                self?.handle(events: events)
            }
    }
    
    private func handle(events: EventsBunch) {
        anytypeAssert(events.localEvents.isEmpty, "Local events with emplty objectId: \(events)", domain: .subscriptionStorage)
        
        for event in events.middlewareEvents {
            switch event.value {
            case .objectDetailsAmend(let data):
                guard let currentDetails = ObjectDetailsStorage.shared.get(id: data.id) else {
                    anytypeAssertionFailure("No details found for ammend: \(data)", domain: .subscriptionStorage)
                    break
                }
                
                let updatedDetails = currentDetails.updated(by: data.details.asDetailsDictionary)
                ObjectDetailsStorage.shared.add(details: updatedDetails)
                
                update(details: updatedDetails, rawSubIds: data.subIds)
            case .accountConfigUpdate:
                break
            default:
                anytypeAssertionFailure("Unupported event \(event)", domain: .subscriptionStorage)
            }
        }
    }
    
    private func update(details: ObjectDetails, rawSubIds: [String]) {
        let subIds: [SubscriptionId] = rawSubIds.compactMap {
            guard let subId = SubscriptionId(rawValue: $0) else {
                anytypeAssertionFailure("Unrecognized subscription: \($0)", domain: .subscriptionStorage)
                return nil
            }
            
            return subId
        }
        
        update(details: details, subIds: subIds)
    }
    
    private func update(details: ObjectDetails, subIds: [SubscriptionId]) {
        for subId in subIds {
            switch subId {
            case .history:
                guard let index = history.firstIndex(where: { $0.id == details.id }) else {
                    anytypeAssertionFailure("No object for update: \(details)", domain: .subscriptionStorage)
                    return
                }
                
                history[index] = details
            }
        }
    }
}
