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
        case video
        case file
        case object

        init(layout: Int) {
            switch layout {
            case LayoutValue.image:
                self = .image
            case LayoutValue.video:
                self = .video
            case LayoutValue.file, LayoutValue.audio, LayoutValue.pdf:
                self = .file
            default:
                self = .object
            }
        }

        var emoji: String {
            switch self {
            case .image: return "📷"
            case .video: return "📹"
            case .file: return "📎"
            case .object: return "📄"
            }
        }

        func localizedText(count: Int) -> String {
            switch self {
            case .image: return Loc.image(count)
            case .video: return Loc.video(count)
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

    func formattedNotificationBody(showSenderPrefix: Bool) -> String {
        let contentPart: String
        if hasAttachments, hasText {
            contentPart = attachmentEmoji + " " + text
        } else if hasAttachments {
            contentPart = attachmentEmoji + " " + localizedAttachmentText(count: attachmentCount)
        } else {
            contentPart = text
        }

        if showSenderPrefix, senderName.isNotEmpty {
            return senderName + ": " + contentPart
        }
        return contentPart
    }
}

// MARK: - DecryptedPushContent Extension

extension DecryptedPushContent {

    // Values from Anytype_Model_SpaceUxType.
    // Services module cannot be linked to the extension
    // (it pulls in Lib.xcframework ~779 MB, exceeding the ~24 MB extension memory limit).
    private enum SpaceUxTypeValue {
        static let data = 1
        static let oneToOne = 4
    }

    var isOneToOne: Bool {
        spaceUxType == SpaceUxTypeValue.oneToOne
    }

    var supportsMultiChats: Bool {
        spaceUxType == SpaceUxTypeValue.data
    }
}

// MARK: - NotificationService

class NotificationService: UNNotificationServiceExtension {
    
    private let decryptionPushContentService: any DecryptionPushContentServiceProtocol = DecryptionPushContentService()
    
    @Injected(\.spaceIconStorage)
    private var spaceIconStorage: any SpaceIconStorageProtocol

    @Injected(\.badgeCountStorage)
    private var badgeCountStorage: any BadgeCountStorageProtocol
    
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
        
        bestAttemptContent.body = decryptedMessage.newMessage
            .formattedNotificationBody(showSenderPrefix: !decryptedMessage.isOneToOne)

        bestAttemptContent.userInfo[DecryptedPushKeys.decryptedMessage] = [
            DecryptedPushKeys.spaceId : decryptedMessage.spaceId,
            DecryptedPushKeys.chatId : decryptedMessage.newMessage.chatId
        ]

        let newBadgeCount = badgeCountStorage.badgeCount + 1
        badgeCountStorage.badgeCount = newBadgeCount
        bestAttemptContent.badge = NSNumber(value: newBadgeCount)

        let spaceName = decryptedMessage.newMessage.spaceName.isNotEmpty ? decryptedMessage.newMessage.spaceName : Loc.untitled
        let title = decryptedMessage.isOneToOne ? decryptedMessage.newMessage.senderName : spaceName
        let avatar = spaceIconStorage.iconLocalUrl(forSpaceId: decryptedMessage.spaceId).map { INImage(url: $0) } ?? nil

        // sender.displayName → rendered as notification Title
        let sender = INPerson(
            personHandle: INPersonHandle(value: nil, type: .unknown),
            nameComponents: nil,
            displayName: title,
            image: avatar,
            contactIdentifier: nil,
            customIdentifier: nil
        )

        let intent: INSendMessageIntent
        if let chatName = decryptedMessage.newMessage.chatName,
           chatName.isNotEmpty,
           decryptedMessage.supportsMultiChats {
            // Group mode: speakableGroupName → rendered as notification Subtitle
            intent = INSendMessageIntent(
                recipients: [makeFakeUser(), makeFakeUser()],
                outgoingMessageType: .outgoingMessageText,
                content: nil,
                speakableGroupName: INSpeakableString(spokenPhrase: chatName),
                conversationIdentifier: decryptedMessage.spaceId,
                serviceName: nil,
                sender: sender,
                attachments: nil
            )
            intent.setImage(avatar, forParameterNamed: \.speakableGroupName)
        } else {
            // Non-group mode: Title only, no subtitle
            intent = INSendMessageIntent(
                recipients: nil,
                outgoingMessageType: .outgoingMessageText,
                content: nil,
                speakableGroupName: nil,
                conversationIdentifier: decryptedMessage.spaceId,
                serviceName: nil,
                sender: sender,
                attachments: nil
            )
        }

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
