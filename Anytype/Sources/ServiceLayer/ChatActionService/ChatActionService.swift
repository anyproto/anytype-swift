import Services
import UIKit
import AnytypeCore

protocol ChatActionServiceProtocol: AnyObject {
    func createMessage(
        chatId: String,
        spaceId: String,
        message: SafeSendable<NSAttributedString>,
        linkedObjects: [ChatLinkedObject],
        replyToMessageId: String?
    ) async throws -> String
}

final class ChatActionService: ChatActionServiceProtocol {
    
    @Injected(\.chatInputConverter)
    private var chatInputConverter: any ChatInputConverterProtocol
    @Injected(\.fileActionsService)
    private var fileActionsService: any FileActionsServiceProtocol
    @Injected(\.chatService)
    private var chatService: any ChatServiceProtocol
    
    func createMessage(
        chatId: String,
        spaceId: String,
        message: SafeSendable<NSAttributedString>,
        linkedObjects: [ChatLinkedObject],
        replyToMessageId: String?
    ) async throws -> String {
        
        var chatMessage = ChatMessage()
        chatMessage.message = chatInputConverter.convert(message: message.value)
        chatMessage.replyToMessageID = replyToMessageId ?? ""
        
        for linkedObject in linkedObjects {
            switch linkedObject {
            case .uploadedObject(let objectDetails):
                var attachment = ChatMessageAttachment()
                attachment.target = objectDetails.id
                attachment.type = .link
                chatMessage.attachments.append(attachment)
            case .localPhotosFile(let chatLocalFile):
                guard let data = chatLocalFile.data else { continue }
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
