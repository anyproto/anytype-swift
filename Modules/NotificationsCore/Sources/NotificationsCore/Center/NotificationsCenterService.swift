import Foundation
import UserNotifications

public protocol NotificationsCenterServiceProtocol: AnyObject, Sendable {
    func removeDeliveredNotifications(for chatIds: [String])
}

public final class NotificationsCenterService: NotificationsCenterServiceProtocol {
    
    public init() {}
    
    public func removeDeliveredNotifications(for chatIds: [String]) {
        let center = UNUserNotificationCenter.current()
        center.getDeliveredNotifications { notifications in
            let idsToRemove = notifications
                .filter {
                    guard let chatId = $0.request.content.userInfo[DecryptedPushKeys.chatId] as? String else {
                        return false
                    }
                    return chatIds.contains(chatId)
                }
                .map { $0.request.identifier }
            center.removeDeliveredNotifications(withIdentifiers: idsToRemove)
        }
    }
}
