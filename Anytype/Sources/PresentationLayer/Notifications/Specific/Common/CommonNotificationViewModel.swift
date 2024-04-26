import Foundation
import Services
import Combine
import ProtobufMessages

@MainActor
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
    
    
    private func startHandle() async {
        subscription = await notificationSubscriptionService.handleUpdate(notificationID: notification.id) { [weak self] notification in
            self?.updateView(notification: notification)
        }
    }
    
    private func updateView(notification: Services.Notification) {
        switch notification.payload {
        case .import(let data):
            title = data.name
        case .export, .requestToJoin, .test: // Without title
            break
        case .galleryImport(let galleryImport):
            title = galleryImport.name
        case .none:
            break
        }
    }
}
