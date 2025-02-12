import Foundation
@preconcurrency import Combine

public actor HandlerKeyStorage<Key: Hashable, Handler: Sendable> {
    
    private var cancellableHandlers = [Key: HandlerStorage<Handler>]()
    
    public init() {}
    
    public func addHandler(key: Key, handler: Handler) async -> AnyCancellable {
        let keyStorage = cancellableHandlers[key] ?? HandlerStorage<Handler>()
        return await keyStorage.addHandler(handler: handler)
    }
    
    public func handlers(key: Key) async -> [Handler] {
        return await cancellableHandlers[key]?.handlers() ?? []
    }
}
