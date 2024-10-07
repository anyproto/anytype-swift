import Services
import UIKit
import AnytypeCore

protocol DiscussionChatActionServiceProtocol: AnyObject {
    func createMessage(
        chatId: String,
        spaceId: String,
        message: SafeSendable<NSAttributedString>,
        linkedObjects: [DiscussionLinkedObject]
    ) async throws
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
        linkedObjects: [DiscussionLinkedObject]
    ) async throws {
        
        var chatMessage = ChatMessage()
        chatMessage.message = discussionInputConverter.convert(message: message.value)
        
        for linkedObject in linkedObjects {
            switch linkedObject {
            case .uploadedObject(let objectDetails):
                var attachment = ChatMessageAttachment()
                attachment.target = objectDetails.id
                attachment.type = .link
                chatMessage.attachments.append(attachment)
            case .localFile(let discussionLocalFile):
                guard let data = discussionLocalFile.data else { continue }
                do {
                    let fileDetails = try await fileActionsService.uploadFileObject(spaceId: spaceId, data: data, origin: .none)
                    var attachment = ChatMessageAttachment()
                    attachment.target = fileDetails.id
                    attachment.type = .link
                    chatMessage.attachments.append(attachment)
                } catch {}
            }
        }
        
        try await chatService.addMessage(chatObjectId: chatId, message: chatMessage)
    }
}
