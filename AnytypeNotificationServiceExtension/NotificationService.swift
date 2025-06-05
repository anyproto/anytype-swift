import UserNotifications
import AnytypeCore
import Loc
import NotificationsCore

class NotificationService: UNNotificationServiceExtension {
    
    private let decryptionPushContentService: any DecryptionPushContentServiceProtocol = DecryptionPushContentService()

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
              let signature = request.content.userInfo[Constants.signature] as? String,
              let signatureData = Data(base64Encoded: signature),
              let keyId = request.content.userInfo[Constants.keyId] as? String else {
            contentHandler(bestAttemptContent)
            return
        }
        
        if let decryptedMessage = decryptionPushContentService.decrypt(encryptedData, keyId: keyId),
           decryptionPushContentService.isValidSignature(senderId: decryptedMessage.senderId, signatureData: signatureData, encryptedData: encryptedData)
        {
            bestAttemptContent.title = decryptedMessage.newMessage.spaceName
            bestAttemptContent.subtitle = decryptedMessage.newMessage.senderName
            
            if decryptedMessage.newMessage.hasAttachments, decryptedMessage.newMessage.hasText {
                bestAttemptContent.body = "📎 " + decryptedMessage.newMessage.text
            } else if decryptedMessage.newMessage.hasAttachments, !decryptedMessage.newMessage.hasText {
                bestAttemptContent.body = "📎 " + Loc.PushNotifications.Message.Attachment.title
            } else {
                bestAttemptContent.body = decryptedMessage.newMessage.text
            }
            
            bestAttemptContent.threadIdentifier = decryptedMessage.newMessage.chatId
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
        static let keyId = "x-any-key-id"
        static let signature = "x-any-signature"
    }
}
