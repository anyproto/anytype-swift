import BlocksModels
import Combine
import AnytypeCore


final class SubscriptionsStorage: ObservableObject {
    
    public static let shared = SubscriptionsStorage()
    
    @Published var history: [ObjectDetails] = []
    @Published var archive: [ObjectDetails] = []
    @Published var shared: [ObjectDetails] = []
    
    private var subscription: AnyCancellable?
    private let service: SubscriptionServiceProtocol = SubscriptionService()
    
    private init() {
        setup()
    }
    
    func toggleSubscription(id: SubscriptionId, _ turnOn: Bool) {
        let details = service.toggleSubscription(id: id, turnOn) ?? []
        details.forEach { ObjectDetailsStorage.shared.add(details: $0) }
        assignCollection(id: id, details: details)
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
        let ids: [SubscriptionId] = rawSubIds.compactMap {
            guard let id = SubscriptionId(rawValue: $0) else {
                anytypeAssertionFailure("Unrecognized subscription: \($0)", domain: .subscriptionStorage)
                return nil
            }
            
            return id
        }
        
        update(details: details, ids: ids)
    }
    
    private func update(details: ObjectDetails, ids: [SubscriptionId]) {
        for id in ids {
            guard let index = indexInCollection(id: id, blockId: details.id) else {
                anytypeAssertionFailure("No object in \(id.rawValue) for update: \(details)", domain: .subscriptionStorage)
                return
            }
            updateCollection(id: id, details: details, index: index)
        }
    }
    
    private func assignCollection(id: SubscriptionId, details: [ObjectDetails]) {
        switch id {
        case .history:
            history = details
        case .archive:
            archive = details
        case .shared:
            shared = details
        }
    }
    
    private func indexInCollection(id: SubscriptionId, blockId: BlockId) -> Int? {
        switch id {
        case .history:
            return history.firstIndex(where: { $0.id == blockId })
        case .archive:
            return archive.firstIndex(where: { $0.id == blockId })
        case .shared:
            return shared.firstIndex(where: { $0.id == blockId })
        }
    }
    
    private func updateCollection(id: SubscriptionId, details: ObjectDetails, index: Int) {
        switch id {
        case .history:
            history[index] = details
        case .archive:
            archive[index] = details
        case .shared:
            shared[index] = details
        }
    }
}
