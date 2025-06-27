import UserNotifications
import AnytypeCore
import Loc
import NotificationsCore
import Factory
import Intents

class NotificationService: UNNotificationServiceExtension {
    
    private let decryptionPushContentService: any DecryptionPushContentServiceProtocol = DecryptionPushContentService()
    
    @Injected(\.spaceIconStorage)
    private var spaceIconStorage: any SpaceIconStorageProtocol
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        guard var bestAttemptContent else {
            return
        }
        
//        if let iconLocalUrl = spaceIconStorage.iconLocalUrl(forSpaceId: "bafyreibmp7vmwsmsddbom45edkjqwj2jygxovb27ol7mjl4nnm3mxpu3im.20ynjxn3b99xk"),
//            let attachment = try? UNNotificationAttachment(identifier: "contact-image", url: iconLocalUrl, options: nil) {
//            bestAttemptContent.attachments = [attachment]
//        }
        
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
//            bestAttemptContent.title = decryptedMessage.newMessage.spaceName
//            bestAttemptContent.subtitle = decryptedMessage.newMessage.senderName
            
            let body: String
            if decryptedMessage.newMessage.hasAttachments, decryptedMessage.newMessage.hasText {
                body = "📎 " + decryptedMessage.newMessage.text
            } else if decryptedMessage.newMessage.hasAttachments, !decryptedMessage.newMessage.hasText {
                body = "📎 " + Loc.PushNotifications.Message.Attachment.title
            } else {
                body = decryptedMessage.newMessage.text
            }
//            bestAttemptContent.body = "\(body): "
            
            bestAttemptContent.userInfo[DecryptedPushKeys.decryptedMessage] = [
                DecryptedPushKeys.spaceId : decryptedMessage.spaceId,
                DecryptedPushKeys.chatId : decryptedMessage.newMessage.chatId
            ]
            
            //            if let iconLocalUrl = spaceIconStorage.iconLocalUrl(forSpaceId: decryptedMessage.spaceId),
            //                let attachment = try? UNNotificationAttachment(identifier: "contact-image", url: iconLocalUrl) {
            //                bestAttemptContent.attachments = [attachment]
            //            }
            
            let avatar = spaceIconStorage.iconLocalUrl(forSpaceId: decryptedMessage.spaceId).map { INImage(url: $0) } ?? nil
            
            let handle = INPersonHandle(value: "", type: .unknown)
            let sender = INPerson(
                personHandle: handle,
                nameComponents: nil,
                displayName: decryptedMessage.newMessage.senderName,
                image: avatar,
                contactIdentifier: nil,
                customIdentifier: nil
            )
            
            let sender2 = INPerson(
                personHandle: handle,
                nameComponents: nil,
                displayName: "",
                image: nil,
                contactIdentifier: nil,
                customIdentifier: nil
            )
            
            let sender3 = INPerson(
                personHandle: handle,
                nameComponents: nil,
                displayName: "",
                image: nil,
                contactIdentifier: nil,
                customIdentifier: nil
            )
            
            let intent = INSendMessageIntent(
                recipients: nil,//[sender2, sender3],
                outgoingMessageType: .outgoingMessageText,
                content: body, // Body
                speakableGroupName: INSpeakableString(spokenPhrase: decryptedMessage.newMessage.spaceName),
                conversationIdentifier: decryptedMessage.newMessage.chatId,
                serviceName: decryptedMessage.newMessage.spaceName,
                sender: sender,
                attachments: nil
            )
            
            if let content = try? bestAttemptContent.updating(from: intent),
                let mutableContent = content.mutableCopy() as? UNMutableNotificationContent {
                bestAttemptContent = mutableContent
            }
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
