import Services
import UIKit
import AnytypeCore

protocol ChatActionServiceProtocol: AnyObject, Sendable {
    func createMessage(
        chatId: String,
        spaceId: String,
        message: SafeSendable<NSAttributedString>,
        linkedObjects: [ChatLinkedObject],
        replyToMessageId: String?,
        useBlocksFormat: Bool
    ) async throws -> String

    func updateMessage(
        chatId: String,
        spaceId: String,
        messageId: String,
        message: SafeSendable<NSAttributedString>,
        linkedObjects: [ChatLinkedObject],
        replyToMessageId: String?,
        useBlocksFormat: Bool
    ) async throws
}

final class ChatActionService: ChatActionServiceProtocol, Sendable {

    private let chatInputConverter: any ChatInputConverterProtocol = Container.shared.chatInputConverter()
    private let fileActionsService: any FileActionsServiceProtocol = Container.shared.fileActionsService()
    private let chatService: any ChatServiceProtocol = Container.shared.chatService()
    private let bookmarkService: any BookmarkServiceProtocol = Container.shared.bookmarkService()
    private let typeProvider: any ObjectTypeProviderProtocol = Container.shared.objectTypeProvider()
    
    func createMessage(
        chatId: String,
        spaceId: String,
        message: SafeSendable<NSAttributedString>,
        linkedObjects: [ChatLinkedObject],
        replyToMessageId: String?,
        useBlocksFormat: Bool
    ) async throws -> String {
        let chatMessage = await makeMessage(chatId: chatId, spaceId: spaceId, message: message, linkedObjects: linkedObjects, replyToMessageId: replyToMessageId, useBlocksFormat: useBlocksFormat)
        return try await chatService.addMessage(chatObjectId: chatId, message: chatMessage)
    }

    func updateMessage(
        chatId: String,
        spaceId: String,
        messageId: String,
        message: SafeSendable<NSAttributedString>,
        linkedObjects: [ChatLinkedObject],
        replyToMessageId: String?,
        useBlocksFormat: Bool
    ) async throws {
        var chatMessage = await makeMessage(chatId: chatId, spaceId: spaceId, message: message, linkedObjects: linkedObjects, replyToMessageId: replyToMessageId, useBlocksFormat: useBlocksFormat)
        chatMessage.id = messageId
        try await chatService.updateMessage(chatObjectId: chatId, message: chatMessage)
    }
    
    // MARK: - Private
    
    private func makeMessage(
        chatId: String,
        spaceId: String,
        message: SafeSendable<NSAttributedString>,
        linkedObjects: [ChatLinkedObject],
        replyToMessageId: String?,
        useBlocksFormat: Bool
    ) async -> ChatMessage {

        var chatMessage = ChatMessage()
        let content = chatInputConverter.convert(message: message.value)
        if useBlocksFormat {
            chatMessage.message = chatInputConverter.convert(message: NSAttributedString("")) // TODO: remove after MW fixes crash on their side
            var textBlock = ChatMessage.MessageBlockText()
            textBlock.text = content.text
            textBlock.marks = content.marks
            var block = ChatMessage.MessageBlock()
            block.content = .text(textBlock)
            chatMessage.blocks = [block]
        } else {
            chatMessage.message = content
        }
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
                if let attachment = try? await uploadFile(spaceId: spaceId, data: data.data, preloadFileId: chatLocalFile.data?.preloadFileId, createdInContext: chatId) {
                    chatMessage.attachments.append(attachment)
                }
            case .localBinaryFile(let binaryFile):
                if let attachment = try? await uploadFile(spaceId: spaceId, data: binaryFile.data, preloadFileId: binaryFile.preloadFileId, createdInContext: chatId) {
                    chatMessage.attachments.append(attachment)
                }
            case .localBookmark(let data):
                guard let url = AnytypeURL(string: data.url) else { continue }
                let type = try? typeProvider.objectType(uniqueKey: ObjectTypeUniqueKey.bookmark, spaceId: spaceId)

                if let bookmark = try? await bookmarkService.createBookmarkObject(
                    spaceId: spaceId,
                    url: url,
                    templateId: type?.defaultTemplateId,
                    origin: .none,
                    createdInContext: chatId,
                    createdInContextRef: ""
                ) {
                    var attachment = ChatMessageAttachment()
                    attachment.target = bookmark.id
                    chatMessage.attachments.append(attachment)
                }
                break
            }
        }

        return chatMessage
    }

    private func uploadFile(spaceId: String, data: FileData, preloadFileId: String?, createdInContext: String) async throws -> ChatMessageAttachment {
        let fileDetails: FileDetails

        if let preloadFileId = preloadFileId {
            fileDetails = try await fileActionsService.uploadPreloadedFileObject(fileId: preloadFileId, spaceId: spaceId, data: data, origin: .none, createdInContext: createdInContext, createdInContextRef: "")
        } else {
            fileDetails = try await fileActionsService.uploadFileObject(spaceId: spaceId, data: data, origin: .none, createdInContext: createdInContext, createdInContextRef: "")
        }

        var attachment = ChatMessageAttachment()
        attachment.target = fileDetails.id
        return attachment
    }
}
