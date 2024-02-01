import Foundation
import Services
import Combine
import ProtobufMessages

final class CommonNotificationViewModel: ObservableObject {
    
    private let notification: Services.Notification
    private let notificationSubscriptionService: NotificationsSubscriptionServiceProtocol
    private var subscription: AnyCancellable?
    
    @Published var title: String = ""
    
    init(notification: Services.Notification, notificationSubscriptionService: NotificationsSubscriptionServiceProtocol) {
        self.notification = notification
        self.notificationSubscriptionService = notificationSubscriptionService
        updateView(notification: notification)
        Task { await startHandle() }
    }
    
    
    func startHandle() async {
        subscription = await notificationSubscriptionService.addHandler { [weak self] events in
            self?.handle(events: events)
        }
    }
    
    private func handle(events: [NotificationEvent]) {
        for event in events {
            switch event {
            case .update(let data):
                guard data.id == notification.id else { continue }
                updateView(notification: notification)
            case .send:
                continue
            }
        }
    }
    
    private func updateView(notification: Services.Notification) {
        switch notification.payload {
        case .import(let data):
            title = data.name
        case .export: // Without title
            break
        case .galleryImport(let galleryImport):
            title = galleryImport.name
        case .none:
            break
        }
    }
}
