import Foundation
import ProtobufMessages
import Combine
import AnytypeCore

public protocol ProcessSubscriptionServiceProtocol: AnyObject {
    func addHandler(handler: @escaping (_ processes: [ProcessEvent]) async -> Void) async -> AnyCancellable
}

public actor ProcessSubscriptionService: ServiceEventsHandlerProtocol, ProcessSubscriptionServiceProtocol {
    
    private var handleStorage = HandlerStorage<(_ processes: [ProcessEvent]) async -> Void>()
    
    public init() {
        ServiceMessageHandlerAdapter.shared.addHandler(handler: self)
    }
    
    // MARK: - ProcessSubscriptionServiceProtocol
    
    public func addHandler(handler: @escaping (_ processes: [ProcessEvent]) async -> Void) async -> AnyCancellable {
        return await handleStorage.addHandler(handler: handler)
    }
    
    // MARK: - ServiceEventsHandlerProtocol
    
    public func handle(_ event: Anytype_Event) async {
        let messages: [ProcessEvent] = event.messages.compactMap { message in
            switch message.value {
            case let .processNew(data):
                return .new(data.process.asModel())
            case let .processUpdate(data):
                return .update(data.process.asModel())
            case let .processDone(data):
                return .done(data.process.asModel())
            default:
                return nil
            }
        }
        for handler in await handleStorage.handlers() {
            await handler(messages)
        }
    }
}
