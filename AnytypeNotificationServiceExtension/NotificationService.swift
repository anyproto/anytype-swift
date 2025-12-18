import UserNotifications
import AnytypeCore
import Loc
import NotificationsCore
import Factory
import Intents

// MARK: - DecryptedPushContent.Message Extension

extension DecryptedPushContent.Message {

    // Layout values from Anytype_Model_ObjectType.Layout
    private enum LayoutValue {
        static let file = 6
        static let image = 8
        static let audio = 15
        static let video = 16
        static let pdf = 20
    }

    private enum AttachmentCategory: Equatable {
        case image
        case file
        case object

        init(layout: Int) {
            switch layout {
            case LayoutValue.image, LayoutValue.video:
                self = .image
            case LayoutValue.file, LayoutValue.audio, LayoutValue.pdf:
                self = .file
            default:
                self = .object
            }
        }

        var emoji: String {
            switch self {
            case .image: return "📷"
            case .file: return "📎"
            case .object: return "📁"
            }
        }

        func localizedText(count: Int) -> String {
            switch self {
            case .image: return Loc.image(count)
            case .file: return Loc.file(count)
            case .object: return Loc.object(count)
            }
        }
    }

    private var resolvedCategory: AttachmentCategory {
        guard let attachments, let firstLayout = attachments.first?.layout else {
            return .object
        }
        
        guard attachments.allSatisfy({ $0.layout == firstLayout }) else {
            return .object
        }
        
        return AttachmentCategory(layout: firstLayout)
    }

    var attachmentEmoji: String {
        resolvedCategory.emoji
    }

    func localizedAttachmentText(count: Int) -> String {
        resolvedCategory.localizedText(count: count)
    }
}

// MARK: - NotificationService

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
            bestAttemptContent.body = decryptedMessage.newMessage.attachmentEmoji + " " + decryptedMessage.newMessage.text
        } else if decryptedMessage.newMessage.hasAttachments, !decryptedMessage.newMessage.hasText {
            let count = decryptedMessage.newMessage.attachmentCount
            bestAttemptContent.body = decryptedMessage.newMessage.attachmentEmoji + " " + decryptedMessage.newMessage.localizedAttachmentText(count: count)
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
