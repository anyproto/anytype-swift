import Services
import UIKit
import AnytypeCore

protocol ChatActionServiceProtocol: AnyObject, Sendable {
    func createMessage(
        chatId: String,
        spaceId: String,
        message: SafeSendable<NSAttributedString>,
        linkedObjects: [ChatLinkedObject],
        replyToMessageId: String?
    ) async throws -> String
    
    func updateMessage(
        chatId: String,
        spaceId: String,
        messageId: String,
        message: SafeSendable<NSAttributedString>,
        linkedObjects: [ChatLinkedObject],
        replyToMessageId: String?
    ) async throws
}

final class ChatActionService: ChatActionServiceProtocol, Sendable {
    
    private let chatInputConverter: any ChatInputConverterProtocol = Container.shared.chatInputConverter()
    private let fileActionsService: any FileActionsServiceProtocol = Container.shared.fileActionsService()
    private let chatService: any ChatServiceProtocol = Container.shared.chatService()
    private let bookmarkService: any BookmarkServiceProtocol = Container.shared.bookmarkService()
    private let typeProvider: any ObjectTypeProviderProtocol = Container.shared.objectTypeProvider()
    private let aiService: any AIServiceProtocol = Container.shared.aiService()
    private let aiConfigBuilder: any AIConfigBuilderProtocol = AIConfigBuilder()
    
    func createMessage(
        chatId: String,
        spaceId: String,
        message: SafeSendable<NSAttributedString>,
        linkedObjects: [ChatLinkedObject],
        replyToMessageId: String?
    ) async throws -> String {
        let chatMessage = await makeMessage(spaceId: spaceId, message: message, linkedObjects: linkedObjects, replyToMessageId: replyToMessageId)
        return try await chatService.addMessage(chatObjectId: chatId, message: chatMessage)
    }
    
    func updateMessage(
        chatId: String,
        spaceId: String,
        messageId: String,
        message: SafeSendable<NSAttributedString>,
        linkedObjects: [ChatLinkedObject],
        replyToMessageId: String?
    ) async throws {
        var chatMessage = await makeMessage(spaceId: spaceId, message: message, linkedObjects: linkedObjects, replyToMessageId: replyToMessageId)
        chatMessage.id = messageId
        try await chatService.updateMessage(chatObjectId: chatId, message: chatMessage)
    }
    
    // MARK: - Private
    
    private func makeMessage(
        spaceId: String,
        message: SafeSendable<NSAttributedString>,
        linkedObjects: [ChatLinkedObject],
        replyToMessageId: String?
    ) async -> ChatMessage {
        
        var chatMessage = ChatMessage()
        chatMessage.message = chatInputConverter.convert(message: message.value)
        chatMessage.replyToMessageID = replyToMessageId ?? ""
        
        for linkedObject in linkedObjects {
            switch linkedObject {
            case .uploadedObject(let objectDetails):
                var attachment = ChatMessageAttachment()
                attachment.target = objectDetails.id
                chatMessage.attachments.append(attachment)
            case .localPhotosFile(let chatLocalFile):
                guard let data = chatLocalFile.data else { continue }
                if let attachment = try? await uploadFile(spaceId: spaceId, data: data.data, preloadFileId: chatLocalFile.data?.preloadFileId) {
                    chatMessage.attachments.append(attachment)
                }
            case .localBinaryFile(let binaryFile):
                if let attachment = try? await uploadFile(spaceId: spaceId, data: binaryFile.data, preloadFileId: binaryFile.preloadFileId) {
                    chatMessage.attachments.append(attachment)
                }
            case .localBookmark(let data):
                guard let url = AnytypeURL(string: data.url) else { continue }
                if FeatureFlags.aiToolInSet {
                    if let config = aiConfigBuilder.makeOpenAIConfig(),
                        let bookmark = try? await aiService.aiObjectCreateFromUrl(spaceId: spaceId, url: url, config: config) {
                        var attachment = ChatMessageAttachment()
                        attachment.target = bookmark.id
                        chatMessage.attachments.append(attachment)
                    }
                } else {
                    let type = try? typeProvider.objectType(uniqueKey: ObjectTypeUniqueKey.bookmark, spaceId: spaceId)
                    
                    if let bookmark = try? await bookmarkService.createBookmarkObject(
                        spaceId: spaceId,
                        url: url,
                        templateId: type?.defaultTemplateId,
                        origin: .none
                    ) {
                        var attachment = ChatMessageAttachment()
                        attachment.target = bookmark.id
                        chatMessage.attachments.append(attachment)
                    }
                }
                break
            }
        }
        
        return chatMessage
    }
    
    private func uploadFile(spaceId: String, data: FileData, preloadFileId: String?) async throws -> ChatMessageAttachment {
        let fileDetails: FileDetails

        if let preloadFileId = preloadFileId {
            fileDetails = try await fileActionsService.uploadPreloadedFileObject(fileId: preloadFileId, spaceId: spaceId, origin: .none)
        } else {
            fileDetails = try await fileActionsService.uploadFileObject(spaceId: spaceId, data: data, origin: .none)
        }

        var attachment = ChatMessageAttachment()
        attachment.target = fileDetails.id
        return attachment
    }
}
