import UserNotifications
import Services

class NotificationService: UNNotificationServiceExtension {
    
    private let decryptionPushContentService: any DecryptionPushContentServiceProtocol = Container.shared.decryptionPushContentService()

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        guard let bestAttemptContent else {
            return
        }
        
        guard let encryptedBase64 = request.content.userInfo[Constants.payload] as? String,
              let encryptedData = Data(base64Encoded: encryptedBase64),
              let spaceId = request.content.userInfo[Constants.spaceKeyId] as? String else {
            contentHandler(bestAttemptContent)
            return
        }
        
        if let decryptedMessage = decryptionPushContentService.decrypt(encryptedData, spaceId: spaceId) {
            bestAttemptContent.title = decryptedMessage.newMessage.text
            bestAttemptContent.userInfo[DecryptedPushKeys.decryptedMessage] = [
                DecryptedPushKeys.spaceId : decryptedMessage.spaceId,
                DecryptedPushKeys.chatId : decryptedMessage.newMessage.chatId
            ]
        }
        
        // Deliver the notification
        contentHandler(bestAttemptContent)
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler, let bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}

extension NotificationService {
    enum Constants {
        static let payload = "x-any-payload"
        static let spaceKeyId = "x-any-key-id"
    }
}
