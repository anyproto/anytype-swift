import Combine

actor EventBunchSubscribtion {
    
    static let `default` = EventBunchSubscribtion()
    private var subscribers = [EventBunchSubscriber]()
    
    private init() {}
    
    func sendEvent(events: EventsBunch) async {
        await subscribers.asyncForEach { subscriber in
            await subscriber.handler?(events)
        }
    }
    
    nonisolated
    func addHandler(_ handler: @escaping @Sendable (_ events: EventsBunch) async -> Void) -> AnyCancellable {
        let subscriber = EventBunchSubscriber(handler: handler)
        Task {
            await addSubscriber(subscriber)
        }
        return AnyCancellable(subscriber)
    }
    
    func stream() -> AsyncStream<EventsBunch> {
        AsyncStream { continuation in
            
            let subscriber = EventBunchSubscriber { bunch in
                continuation.yield(bunch)
            }
            
            addSubscriber(subscriber)
            
            continuation.onTermination = { _ in
                subscriber.cancel()
            }
        }
    }
    
    private func addSubscriber(_ subscriber: EventBunchSubscriber) {
        subscribers.removeAll(where: \.handler.isNil)
        subscribers.append(subscriber)
    }
}

private class EventBunchSubscriber: Cancellable, @unchecked Sendable {
    
    private(set) var handler:  ((_ events: EventsBunch) async -> Void)?
    
    init(handler: @escaping (_ events: EventsBunch) async -> Void) {
        self.handler = handler
    }
    
    func cancel() {
        handler = nil
    }
}
