import Services
import UIKit
import AnytypeCore

struct ChatActionSendError: Error, LocalizedError {
    let underlyingError: any Error
    /// Input linked objects with successfully uploaded ones replaced by `.uploadedObject`,
    /// so a retry reuses the created objects instead of re-uploading and orphaning them
    let updatedLinkedObjects: [ChatLinkedObject]

    var errorDescription: String? { underlyingError.localizedDescription }
}

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
        let (chatMessage, updatedLinkedObjects) = try await makeMessage(chatId: chatId, spaceId: spaceId, message: message, linkedObjects: linkedObjects, replyToMessageId: replyToMessageId, useBlocksFormat: useBlocksFormat)
        do {
            return try await chatService.addMessage(chatObjectId: chatId, message: chatMessage)
        } catch {
            throw ChatActionSendError(underlyingError: error, updatedLinkedObjects: updatedLinkedObjects)
        }
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
        let (madeMessage, updatedLinkedObjects) = try await makeMessage(chatId: chatId, spaceId: spaceId, message: message, linkedObjects: linkedObjects, replyToMessageId: replyToMessageId, useBlocksFormat: useBlocksFormat)
        var chatMessage = madeMessage
        chatMessage.id = messageId
        do {
            try await chatService.updateMessage(chatObjectId: chatId, message: chatMessage)
        } catch {
            throw ChatActionSendError(underlyingError: error, updatedLinkedObjects: updatedLinkedObjects)
        }
    }
    
    // MARK: - Private
    
    private func makeMessage(
        chatId: String,
        spaceId: String,
        message: SafeSendable<NSAttributedString>,
        linkedObjects: [ChatLinkedObject],
        replyToMessageId: String?,
        useBlocksFormat: Bool
    ) async throws -> (message: ChatMessage, updatedLinkedObjects: [ChatLinkedObject]) {

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

        var updatedLinkedObjects = linkedObjects

        do {
            for (index, linkedObject) in linkedObjects.enumerated() {
                switch linkedObject {
                case .uploadedObject(let objectDetails):
                    if useBlocksFormat {
                        var linkBlock = ChatMessage.MessageBlockLink()
                        linkBlock.targetObjectID = objectDetails.id
                        linkBlock.type = objectDetails.resolvedLayoutValue.blockLinkType
                        var block = ChatMessage.MessageBlock()
                        block.content = .link(linkBlock)
                        chatMessage.blocks.append(block)
                    } else {
                        var attachment = ChatMessageAttachment()
                        attachment.target = objectDetails.id
                        attachment.type = .link
                        chatMessage.attachments.append(attachment)
                    }
                case .localPhotosFile(let chatLocalFile):
                    guard let data = chatLocalFile.data else { continue }
                    // A failed upload must fail the send — silently dropping the attachment loses user data
                    let fileDetails = try await uploadFile(spaceId: spaceId, data: data.data, preloadFileId: chatLocalFile.data?.preloadFileId, createdInContext: chatId)
                    updatedLinkedObjects[index] = .uploadedObject(MessageAttachmentDetails(fileDetails: fileDetails))
                    if useBlocksFormat {
                        var linkBlock = ChatMessage.MessageBlockLink()
                        linkBlock.targetObjectID = fileDetails.id
                        linkBlock.type = fileDetails.blockLinkType
                        var block = ChatMessage.MessageBlock()
                        block.content = .link(linkBlock)
                        chatMessage.blocks.append(block)
                    } else {
                        var attachment = ChatMessageAttachment()
                        attachment.target = fileDetails.id
                        chatMessage.attachments.append(attachment)
                    }
                case .localBinaryFile(let binaryFile):
                    let fileDetails = try await uploadFile(spaceId: spaceId, data: binaryFile.data, preloadFileId: binaryFile.preloadFileId, createdInContext: chatId)
                    updatedLinkedObjects[index] = .uploadedObject(MessageAttachmentDetails(fileDetails: fileDetails))
                    if useBlocksFormat {
                        var linkBlock = ChatMessage.MessageBlockLink()
                        linkBlock.targetObjectID = fileDetails.id
                        linkBlock.type = fileDetails.blockLinkType
                        var block = ChatMessage.MessageBlock()
                        block.content = .link(linkBlock)
                        chatMessage.blocks.append(block)
                    } else {
                        var attachment = ChatMessageAttachment()
                        attachment.target = fileDetails.id
                        chatMessage.attachments.append(attachment)
                    }
                case .localBookmark(let data):
                    guard let url = AnytypeURL(string: data.url) else { continue }
                    let type = try? typeProvider.objectType(uniqueKey: ObjectTypeUniqueKey.bookmark, spaceId: spaceId)

                    let bookmark = try await bookmarkService.createBookmarkObject(
                        spaceId: spaceId,
                        url: url,
                        templateId: type?.defaultTemplateId,
                        origin: .none,
                        createdInContext: chatId,
                        createdInContextRef: ""
                    )
                    updatedLinkedObjects[index] = .uploadedObject(MessageAttachmentDetails(details: bookmark))

                    if useBlocksFormat {
                        var linkBlock = ChatMessage.MessageBlockLink()
                        linkBlock.targetObjectID = bookmark.id
                        linkBlock.type = .bookmark
                        var block = ChatMessage.MessageBlock()
                        block.content = .link(linkBlock)
                        chatMessage.blocks.append(block)
                    } else {
                        var attachment = ChatMessageAttachment()
                        attachment.target = bookmark.id
                        chatMessage.attachments.append(attachment)
                    }
                }
            }
        } catch {
            // A failure on one item must not lose the objects already created for the previous ones
            throw ChatActionSendError(underlyingError: error, updatedLinkedObjects: updatedLinkedObjects)
        }

        return (chatMessage, updatedLinkedObjects)
    }

    private func uploadFile(spaceId: String, data: FileData, preloadFileId: String?, createdInContext: String) async throws -> FileDetails {
        if let preloadFileId {
            return try await fileActionsService.uploadPreloadedFileObject(fileId: preloadFileId, spaceId: spaceId, data: data, origin: .none, createdInContext: createdInContext, createdInContextRef: "")
        } else {
            return try await fileActionsService.uploadFileObject(spaceId: spaceId, data: data, origin: .none, createdInContext: createdInContext, createdInContextRef: "")
        }
    }
}
