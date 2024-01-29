import Foundation
import Combine
import ProtobufMessages

protocol NotificationsSubscriptionServiceProtocol: AnyObject {
    func addHandler(handler: @escaping (_ events: [NotificationEvent]) async -> Void) -> AnyCancellable
}

actor NotificationsSubscriptionService: ServiceEventsHandlerProtocol {
    
    private var subscribers = [NotificationSubscriber]()
    
    init() {
        ServiceMessageHandlerAdapter.shared.addHandler(handler: self)
    }
    
    nonisolated
    func addHandler(handler: @escaping (_ events: [NotificationEvent]) async -> Void) -> AnyCancellable {
        let subscriber = NotificationSubscriber(handler: handler)
        Task {
            await addSubscriber(subscriber)
        }
        return AnyCancellable(subscriber)
    }
    
    private func addSubscriber(_ subscriber: NotificationSubscriber) {
        subscribers.removeAll(where: \.handler.isNil)
        subscribers.append(subscriber)
    }
    
    // MARK: - ServiceEventsHandlerProtocol
    
    func handle(_ event: Anytype_Event) async {
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
        for subscriber in subscribers {
            await subscriber.handler?(messages)
        }
    }

}

private class NotificationSubscriber: Cancellable {
    
    private(set) var handler:  ((_ events: [NotificationEvent]) async -> Void)?
    
    init(handler: @escaping (_ events: [NotificationEvent]) async -> Void) {
        self.handler = handler
    }
    
    func cancel() {
        handler = nil
    }
}
