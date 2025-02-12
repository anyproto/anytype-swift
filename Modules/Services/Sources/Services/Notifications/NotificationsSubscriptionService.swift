import Foundation
@preconcurrency import Combine
import ProtobufMessages
import AnytypeCore

public protocol NotificationsSubscriptionServiceProtocol: AnyObject, Sendable {
    func addHandler(handler: @escaping @Sendable (_ events: [NotificationEvent]) async -> Void) async -> AnyCancellable
}

actor NotificationsSubscriptionService: ServiceEventsHandlerProtocol, NotificationsSubscriptionServiceProtocol {
    
    private var handleStorage = HandlerStorage<@Sendable (_ events: [NotificationEvent]) async -> Void>()
    
    init() {
        ServiceMessageHandlerAdapter.shared.addHandler(handler: self)
    }
    
    // MARK: - NotificationsSubscriptionServiceProtocol
    
    public func addHandler(handler: @escaping @Sendable (_ events: [NotificationEvent]) async -> Void) async -> AnyCancellable {
        await handleStorage.addHandler(handler: handler)
    }
    
    // MARK: - ServiceEventsHandlerProtocol
    
    public func handle(_ event: Anytype_Event) async {
        let messages: [NotificationEvent] = event.messages.compactMap { message in
            switch message.value {
            case let .notificationSend(data):
                return .send(data.notification.asModel())
            case let .notificationUpdate(data):
                return .update(data.notification.asModel())
            default:
                return nil
            }
        }
        for handler in await handleStorage.handlers() {
            await handler(messages)
        }
    }
}
