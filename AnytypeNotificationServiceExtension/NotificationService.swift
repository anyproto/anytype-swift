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
        
        guard let bestAttemptContent else {
            return
        }
        
        guard let encryptedBase64 = request.content.userInfo[PushNotificationKeys.payload] as? String,
              let encryptedData = Data(base64Encoded: encryptedBase64),
              let signature = request.content.userInfo[PushNotificationKeys.signature] as? String,
              let signatureData = Data(base64Encoded: signature),
              let keyId = request.content.userInfo[PushNotificationKeys.keyId] as? String else {
            contentHandler(bestAttemptContent)
            return
        }
        
        guard let decryptedMessage = decryptionPushContentService.decrypt(encryptedData, keyId: keyId),
              decryptionPushContentService.isValidSignature(senderId: decryptedMessage.senderId, signatureData: signatureData, encryptedData: encryptedData) else {
            contentHandler(bestAttemptContent)
            return
        }
        
        if decryptedMessage.newMessage.hasAttachments, decryptedMessage.newMessage.hasText {
            bestAttemptContent.body = "📎 " + decryptedMessage.newMessage.text
        } else if decryptedMessage.newMessage.hasAttachments, !decryptedMessage.newMessage.hasText {
            bestAttemptContent.body = "📎 " + Loc.PushNotifications.Message.Attachment.title
        } else {
            bestAttemptContent.body = decryptedMessage.newMessage.text
        }

        bestAttemptContent.userInfo[DecryptedPushKeys.decryptedMessage] = [
            DecryptedPushKeys.spaceId : decryptedMessage.spaceId,
            DecryptedPushKeys.chatId : decryptedMessage.newMessage.chatId
        ]
        
        let sender = INPerson(
            personHandle: INPersonHandle(value: nil, type: .unknown),
            nameComponents: nil,
            displayName: decryptedMessage.newMessage.senderName,
            image: nil,
            contactIdentifier: nil,
            customIdentifier: nil
        )
        
        let spaceName = decryptedMessage.newMessage.spaceName.isNotEmpty ? decryptedMessage.newMessage.spaceName : Loc.untitled
        let intent = INSendMessageIntent(
            recipients: [makeFakeUser(), makeFakeUser()], // The system identifies the message as a group message and displays the group name
            outgoingMessageType: .outgoingMessageText,
            content: nil,
            speakableGroupName: INSpeakableString(spokenPhrase: spaceName),
            conversationIdentifier: decryptedMessage.spaceId,
            serviceName: nil,
            sender: sender,
            attachments: nil
        )
        
        let avatar = spaceIconStorage.iconLocalUrl(forSpaceId: decryptedMessage.spaceId).map { INImage(url: $0) } ?? nil
        intent.setImage(avatar, forParameterNamed: \.speakableGroupName)
        
        do {
            let update = try bestAttemptContent.updating(from: intent)
            contentHandler(update)
        } catch {
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler, let bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
    private func makeFakeUser() -> INPerson {
        let uuid = UUID().uuidString
        return INPerson(
            personHandle: INPersonHandle(value: uuid, type: .unknown),
            nameComponents: nil,
            displayName: uuid,
            image: nil,
            contactIdentifier: nil,
            customIdentifier: nil
        )
    }
}
