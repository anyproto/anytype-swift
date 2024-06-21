import Foundation

public enum NotificationEvent: Sendable {
    case send(Notification)
    case update(Notification)
}
