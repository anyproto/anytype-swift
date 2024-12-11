import Foundation
import AnytypeCore

protocol ParticipantsSubscriptionProviderProtocol: AnyObject {
    @MainActor
    func subscription(spaceId: String) -> any ParticipantsSubscriptionProtocol
}

final class ParticipantsSubscriptionProvider: ParticipantsSubscriptionProviderProtocol {
    
    private let lock = NSLock()
    private var cache = [String: Weak<ParticipantsSubscription>]()
    
    // MARK: - ParticipantsSubscriptionProviderProtocol
    @MainActor
    func subscription(spaceId: String) -> any ParticipantsSubscriptionProtocol {
        
        lock.lock()
        defer { lock.unlock() }
        
        if let storage = cache[spaceId]?.value {
            return storage
        }
        
        let storage = ParticipantsSubscription(spaceId: spaceId)
        cache[spaceId] = Weak(value: storage)
        return storage
    }
}
