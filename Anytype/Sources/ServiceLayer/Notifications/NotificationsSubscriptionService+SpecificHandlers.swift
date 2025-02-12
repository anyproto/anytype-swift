import Foundation
import Combine
import AnytypeCore
import Services

extension NotificationsSubscriptionServiceProtocol {
    
    func handleUpdate(
        notificationID: String,
        handler: @escaping @Sendable (Services.Notification) async -> Void
    ) async -> AnyCancellable {
        await addHandler { events in
            for event in events {
                switch event {
                case .update(let data):
                    guard data.id == notificationID else { continue }
                    await handler(data)
                case .send:
                    continue
                }
            }
        }
    }
    
    func handleGalleryImportUpdate(
        notificationID: String,
        completion: @escaping @Sendable (NotificationGalleryImport) async -> Void
    ) async -> AnyCancellable {
        await handleUpdate(notificationID: notificationID) { notification in
            switch notification.payload {
            case .galleryImport(let data):
                await completion(NotificationGalleryImport(common: notification, galleryImport: data))
            default:
                anytypeAssertionFailure(
                    "Try handle notification with different type",
                    info: ["notification": String(describing: notification.payload.self)]
                )
            }
        }
    }
}
