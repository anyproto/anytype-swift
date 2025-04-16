import UserNotifications
import Services

class NotificationService: UNNotificationServiceExtension {
    
    private let decryptionPushMessageService: any DecryptionPushMessageServiceProtocol = Container.shared.decryptionPushMessageService()

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
              let spaceId = request.content.userInfo[Constants.spaceId] as? String else {
            contentHandler(bestAttemptContent)
            return
        }
        
        if let decryptedMessage = decryptionPushMessageService.decrypt(encryptedData, spaceId: spaceId) {
            bestAttemptContent.title = decryptedMessage.newMessage.text
        }
        
        // Deliver the notification
        contentHandler(bestAttemptContent)
    }
}

extension NotificationService {
    enum Constants {
        static let payload = "x-any-payload"
        static let spaceId = "x-any-key-id"
    }
}
