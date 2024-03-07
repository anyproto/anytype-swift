import Foundation
import Services
import Combine
import AnytypeCore

protocol SubscriptionStorageProviderProtocol: AnyObject {
    func createSubscriptionStorage(subId: String) -> SubscriptionStorageProtocol
}

final class SubscriptionStorageProvider: SubscriptionStorageProviderProtocol {
    
    // MARK: - Private properties
    
    @Injected(\.subscriptionToggler)
    private var toggler: SubscriptionTogglerProtocol
    
    private let lock = NSLock()
    // NSMapTable<NSString, SubscriptionStorage>.strongToWeakObjects() crashed on objc_loadWeakRetained method for iphone se 1 gen ios 15
    private var subscriptionCache = [String: Weak<SubscriptionStorage>]()
    
    // MARK: - Public properties
    
    func createSubscriptionStorage(subId: String) -> SubscriptionStorageProtocol {
        
        lock.lock()
        defer { lock.unlock() }
        
        if let storage = subscriptionCache[subId]?.value {
            anytypeAssertionFailure("Subscription storage already created", info: ["sub id": subId])
            return storage
        }
        
        let storage = SubscriptionStorage(subId: subId, detailsStorage: ObjectDetailsStorage(), toggler: toggler)
        subscriptionCache[subId] = Weak(value: storage)
        return storage
    }
}
