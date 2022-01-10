import BlocksModels
import Combine
import AnytypeCore


final class SubscriptionsStorage: ObservableObject {
    
    public static let shared = SubscriptionsStorage()
    
    @Published var history: [ObjectDetails] = []
    @Published var archive: [ObjectDetails] = []
    @Published var shared: [ObjectDetails] = []
    @Published var sets: [ObjectDetails] = []
    
    private var subscription: AnyCancellable?
    private let service: SubscriptionServiceProtocol = SubscriptionService()
    private let detailsStorage = ObjectDetailsStorage.shared
    
    private init() {
        setup()
    }
    
    func toggleSubscriptions(ids: [SubscriptionId], _ turnOn: Bool) {
        ids.forEach { toggleSubscription(id: $0, turnOn) }
    }
    
    func toggleSubscription(id: SubscriptionId, _ turnOn: Bool) {
        let details = service.toggleSubscription(id: id, turnOn) ?? []
        details.forEach { detailsStorage.add(details: $0) }
        assignCollection(id: id, details: details)
    }
    
    // MARK: - Private
    private let dependencySubscriptionSuffix = "/dep"
    
    private var objectIds: [String] {
        SubscriptionId.allCases.map { $0.rawValue } + [""]
    }
    
    private func setup() {
        subscription = NotificationCenter.Publisher(
            center: .default,
            name: .middlewareEvent,
            object: nil
        )
            .compactMap { $0.object as? EventsBunch }
            .filter { [weak self] in
                self?.objectIds.contains($0.objectId) ?? false
            }
            .sink { [weak self] events in
                self?.handle(events: events)
            }
    }
    
    private func handle(events: EventsBunch) {
        anytypeAssert(events.localEvents.isEmpty, "Local events with emplty objectId: \(events)", domain: .subscriptionStorage)
        
        for event in events.middlewareEvents {
            switch event.value {
            case .objectDetailsAmend(let data):
                let currentDetails = detailsStorage.get(id: data.id) ?? ObjectDetails.empty(id: data.id)
                
                let updatedDetails = currentDetails.updated(by: data.details.asDetailsDictionary)
                detailsStorage.add(details: updatedDetails)
                
                update(details: updatedDetails, rawSubIds: data.subIds)
            case .subscriptionPosition(let position):
                guard let subId = SubscriptionId(rawValue: events.objectId) else {
                    anytypeAssertionFailure("Unsupported object id \(events.objectId) in subscriptionPosition", domain: .subscriptionStorage)
                    break
                }
                
                guard let index = indexInCollection(id: subId, blockId: position.id) else {
                    anytypeAssertionFailure("No object in \(subId) for id \(position.id)", domain: .subscriptionStorage)
                    break
                }
                
                let insertIndex: Int
                if position.afterID == "" {
                    insertIndex = 0
                } else {
                    guard let afterIndex = indexInCollection(id: subId, blockId: position.afterID) else {
                        anytypeAssertionFailure("No object in \(subId) for afterId \(position.afterID)", domain: .subscriptionStorage)
                        return
                    }
                    
                    insertIndex = afterIndex + 1
                }
                moveElementInCollection(id: subId, from: index, to: insertIndex)
            case .subscriptionAdd(let data):
                guard let subId = SubscriptionId(rawValue: events.objectId) else {
                    anytypeAssertionFailure("Unsupported object id \(events.objectId) in subscriptionRemove", domain: .subscriptionStorage)
                    break
                }
                
                guard let details = detailsStorage.get(id: data.id) else {
                    anytypeAssertionFailure("No details found for id \(data.id)", domain: .subscriptionStorage)
                    return
                }
                
                guard data.afterID != "" else {
                    addElementInCollection(id: subId, details: details, at: 0)
                    return
                }
                
                guard let index = indexInCollection(id: subId, blockId: data.afterID) else {
                    anytypeAssertionFailure("No object in \(subId) for id \(data.id)", domain: .subscriptionStorage)
                    break
                }
                addElementInCollection(id: subId, details: details, at: index)
            case .subscriptionRemove(let remove):
                guard let subId = SubscriptionId(rawValue: events.objectId) else {
                    anytypeAssertionFailure("Unsupported object id \(events.objectId) in subscriptionRemove", domain: .subscriptionStorage)
                    break
                }
                
                guard let index = indexInCollection(id: subId, blockId: remove.id) else {
                    anytypeAssertionFailure("No object in \(subId) for id \(remove.id)", domain: .subscriptionStorage)
                    break
                }
                removeElementInCollection(id: subId, at: index)
            case .objectRemove:
                break // unsupported (Not supported in middleware converter also)
            case .subscriptionCounters:
                break // unsupported for now. Used for pagination
            case .accountConfigUpdate:
                break
            default:
                anytypeAssertionFailure("Unupported event \(event)", domain: .subscriptionStorage)
            }
        }
    }
    
    private func update(details: ObjectDetails, rawSubIds: [String]) {
        let ids: [SubscriptionId] = rawSubIds.compactMap { rawId in
            guard let id = SubscriptionId(rawValue: rawId) else {
                if !rawId.hasSuffix(dependencySubscriptionSuffix) {
                    anytypeAssertionFailure("Unrecognized subscription: \(rawId)", domain: .subscriptionStorage)
                }
                return nil
            }
            
            return id
        }
        
        update(details: details, ids: ids)
    }
    
    private func update(details: ObjectDetails, ids: [SubscriptionId]) {
        for id in ids {
            guard let index = indexInCollection(id: id, blockId: details.id) else {
                return // May be possible on ammend for new object
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
        case .sets:
            sets = details
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
        case .sets:
            return sets.firstIndex(where: { $0.id == blockId })
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
        case .sets:
            sets[index] = details
        }
    }
    
    private func moveElementInCollection(id: SubscriptionId, from index: Int, to insertIndex: Int) {
        switch id {
        case .history:
            history.moveElement(from: index, to: insertIndex)
        case .archive:
            archive.moveElement(from: index, to: insertIndex)
        case .shared:
            shared.moveElement(from: index, to: insertIndex)
        case .sets:
            sets.moveElement(from: index, to: insertIndex)
        }
    }
    
    private func addElementInCollection(id: SubscriptionId, details: ObjectDetails, at index: Int) {
        switch id {
        case .history:
            history.insert(details, at: index)
        case .archive:
            archive.insert(details, at: index)
        case .shared:
            shared.insert(details, at: index)
        case .sets:
            sets.insert(details, at: index)
        }
    }
    
    private func removeElementInCollection(id: SubscriptionId, at index: Int) {
        switch id {
        case .history:
            history.remove(at: index)
        case .archive:
            archive.remove(at: index)
        case .shared:
            shared.remove(at: index)
        case .sets:
            sets.remove(at: index)
        }
    }
}
