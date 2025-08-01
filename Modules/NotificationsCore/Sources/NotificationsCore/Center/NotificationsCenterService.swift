import Foundation
import UserNotifications

public protocol NotificationsCenterServiceProtocol: AnyObject, Sendable {
    func removeDeliveredNotifications(for chatIds: [String])
    func removeDeliveredNotifications(for groupId: String)
}

public final class NotificationsCenterService: NotificationsCenterServiceProtocol {
    
    public init() {}
    
    public func removeDeliveredNotifications(for chatIds: [String]) {
        let center = UNUserNotificationCenter.current()
        center.getDeliveredNotifications { notifications in
            let idsToRemove = notifications
                .filter {
                    guard let decryptedMessage = $0.request.content.userInfo[DecryptedPushKeys.decryptedMessage] as? [String : Any],
                          let chatId = decryptedMessage[DecryptedPushKeys.chatId] as? String else {
                        return false
                    }
                    return chatIds.contains(chatId)
                }
                .map { $0.request.identifier }
            center.removeDeliveredNotifications(withIdentifiers: idsToRemove)
        }
    }
    
    public func removeDeliveredNotifications(for groupId: String) {
        let center = UNUserNotificationCenter.current()
        center.getDeliveredNotifications { notifications in
            let idsToRemove = notifications
                .filter {
                    guard let id = $0.request.content.userInfo[PushNotificationKeys.groupId] as? String else {
                        return false
                    }
                    return id == groupId
                }
                .map { $0.request.identifier }
            center.removeDeliveredNotifications(withIdentifiers: idsToRemove)
        }
    }
}
