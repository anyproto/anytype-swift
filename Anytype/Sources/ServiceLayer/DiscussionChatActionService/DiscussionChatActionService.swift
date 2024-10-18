import Services
import UIKit
import AnytypeCore

protocol DiscussionChatActionServiceProtocol: AnyObject {
    func createMessage(
        chatId: String,
        spaceId: String,
        message: SafeSendable<NSAttributedString>,
        linkedObjects: [DiscussionLinkedObject],
        replyToMessageId: String?
    ) async throws -> String
}

final class DiscussionChatActionService: DiscussionChatActionServiceProtocol {
    
    @Injected(\.discussionInputConverter)
    private var discussionInputConverter: any DiscussionInputConverterProtocol
    @Injected(\.fileActionsService)
    private var fileActionsService: any FileActionsServiceProtocol
    @Injected(\.chatService)
    private var chatService: any ChatServiceProtocol
    
    func createMessage(
        chatId: String,
        spaceId: String,
        message: SafeSendable<NSAttributedString>,
        linkedObjects: [DiscussionLinkedObject],
        replyToMessageId: String?
    ) async throws -> String {
        
        var chatMessage = ChatMessage()
        chatMessage.message = discussionInputConverter.convert(message: message.value)
        chatMessage.replyToMessageID = replyToMessageId ?? ""
        
        for linkedObject in linkedObjects {
            switch linkedObject {
            case .uploadedObject(let objectDetails):
                var attachment = ChatMessageAttachment()
                attachment.target = objectDetails.id
                attachment.type = .link
                chatMessage.attachments.append(attachment)
            case .localPhotosFile(let discussionLocalFile):
                guard let data = discussionLocalFile.data else { continue }
                if let attachment = try? await uploadFile(spaceId: spaceId, data: data) {
                    chatMessage.attachments.append(attachment)
                }
            case .localBinaryFile(let data):
                if let attachment = try? await uploadFile(spaceId: spaceId, data: data) {
                    chatMessage.attachments.append(attachment)
                }
            }
        }
        
        return try await chatService.addMessage(chatObjectId: chatId, message: chatMessage)
    }
    
    private func uploadFile(spaceId: String, data: FileData) async throws -> ChatMessageAttachment {
        let fileDetails = try await fileActionsService.uploadFileObject(spaceId: spaceId, data: data, origin: .none)
        var attachment = ChatMessageAttachment()
        attachment.target = fileDetails.id
        attachment.type = .link
        return attachment
    }
}
