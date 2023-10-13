import Foundation
import Services
import Combine
import AnytypeCore

protocol SubscriptionStorageProviderProtocol: AnyObject {
    func createSubscriptionStorage(subId: String) -> SubscriptionStorageProtocol
}

final class SubscriptionStorageProvider: SubscriptionStorageProviderProtocol {
    
    // MARK: - Private properties
    
    private let toggler: SubscriptionTogglerProtocol
    
    private let lock = NSLock()
    private var subscriptionCache = NSMapTable<NSString, SubscriptionStorage>.strongToWeakObjects()
    
    // MARK: - Public properties
    
    nonisolated init(toggler: SubscriptionTogglerProtocol) {
        self.toggler = toggler
    }
    
    func createSubscriptionStorage(subId: String) -> SubscriptionStorageProtocol {
        
        lock.lock()
        defer { lock.unlock() }
        
        if let storage = subscriptionCache.object(forKey: subId as NSString) {
            anytypeAssertionFailure("Subscription storage already created", info: ["sub id": subId])
            return storage
        }
        
        let storage = SubscriptionStorage(subId: subId, detailsStorage: ObjectDetailsStorage(), toggler: toggler)
        subscriptionCache.setObject(storage, forKey: subId as NSString)
        return storage
    }
}
