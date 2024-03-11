import Foundation
import Combine

public actor HandlerStorage<Handler> {
    
    private var cancellableHandlers = [CancellableHandler<Handler>]()
    
    public init() {}
    
    public func addHandler(handler: Handler) -> AnyCancellable {
        let storedHandler = CancellableHandler(handler: handler)
        cancellableHandlers.removeAll(where: \.handler.isNil)
        cancellableHandlers.append(storedHandler)
        return AnyCancellable(storedHandler)
    }
    
    public func handlers() -> [Handler] {
        cancellableHandlers.compactMap { $0.handler }
    }
}

private class CancellableHandler<Handler>: Cancellable {
    
    private(set) var handler: Handler?
    
    init(handler: Handler) {
        self.handler = handler
    }
    
    func cancel() {
        handler = nil
    }
}
