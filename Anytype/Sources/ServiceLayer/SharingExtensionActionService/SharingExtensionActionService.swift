import SwiftUI
import SharedContentManager
import Services
import AnytypeCore
import Factory
import Collections

protocol SharingExtensionActionServiceProtocol: AnyObject, Sendable {
    func saveObjects(
        spaceId: String,
        content: SharedContent,
        linkToObjects: [ObjectDetails],
        chatId: String?,
        comment: String
    ) async throws
}

private enum SharedSavedContentItem {
    case text(String)
    case bookmark(ObjectDetails)
    case file(FileDetails)
    
    var objectId: String? {
        switch self {
        case .text:
            nil
        case .bookmark(let objectDetails):
            objectDetails.id
        case .file(let fileDetails):
            fileDetails.id
        }
    }
}

actor SharingExtensionActionService: SharingExtensionActionServiceProtocol {
    
    @Injected(\.bookmarkService)
    private var bookmarkService: any BookmarkServiceProtocol
    @Injected(\.fileActionsService)
    private var fileService: any FileActionsServiceProtocol
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol
    @Injected(\.blockService)
    private var blockService: any BlockServiceProtocol
    @Injected(\.pasteboardMiddleService)
    private var pasteboardMiddlewareService: any PasteboardMiddlewareServiceProtocol
    @Injected(\.chatService)
    private var chatService: any ChatServiceProtocol
    
    func saveObjects(
        spaceId: String,
        content: SharedContent,
        linkToObjects: [ObjectDetails],
        chatId: String?,
        comment: String
    ) async throws {
        await objectTypeProvider.prepareData(spaceId: spaceId)
        
        // Create objects for media & bookmarks
        let contentItems = try await createObjectsFromSharedContent(spaceId: spaceId, content: content)
        
        try await linkToObjectFlow(spaceId: spaceId, content: content, savedContent: contentItems, linkToObjects: linkToObjects)
        
        if let chatId {
            try await createMessageToChatFlow(spaceId: spaceId, content: content, savedContent: contentItems, chatId: chatId, comment: comment)
        }
    }
    
    // MARK: - Private
    
    private func linkToObjectFlow(
        spaceId: String,
        content: SharedContent,
        savedContent: [SharedSavedContentItem],
        linkToObjects: [ObjectDetails]
    ) async throws {
        let textItems = content.items.filter { $0.isText }
        if (content.title?.isNotEmpty ?? false) || textItems.isNotEmpty {
            let noteObject = try await createContainer(spaceId: spaceId, title: content.title)
            try await createBlocks(object: noteObject, contentItems: savedContent)
            
            for linkToObject in linkToObjects {
                try await linkTo(object: linkToObject, linkedObjectId: noteObject.id)
            }
        } else {
            for linkToObject in linkToObjects {
                try await createBlocks(object: linkToObject, contentItems: savedContent)
            }
        }
    }
    
    private func createMessageToChatFlow(
        spaceId: String,
        content: SharedContent,
        savedContent: [SharedSavedContentItem],
        chatId: String,
        comment: String
    ) async throws {
        
        var fullMessage: String = content.title ?? ""
        // OrderedSet for remove duplicates
        // User can select two images from gallery, but there are the same. Middleware will make a one object
        var attachments = OrderedSet<ChatMessageAttachment>()
        var countOfImages: Int = 0
        
        for savedContentItem in savedContent {
            switch savedContentItem {
            case .text(let text):
                fullMessage.append(text)
            case .bookmark(let objectDetails):
                var attachment = ChatMessageAttachment()
                attachment.target = objectDetails.id
                attachments.append(attachment)
            case .file(let fileDetails):
                var attachment = ChatMessageAttachment()
                attachment.target = fileDetails.id
                attachments.append(attachment)
                if fileDetails.fileContentType == .image {
                    countOfImages += 1
                }
            }
        }
        
        let onlyImages = countOfImages == attachments.count && (content.title?.isEmpty ?? true)
        
        let batches = Array(attachments).chunked(into: 10)
        
        for (index, batch) in batches.enumerated() {
            var chatMessageContent = ChatMessageContent()
            chatMessageContent.text = (index == 0 && onlyImages) ? comment : ""
            
            var chatMessage = ChatMessage()
            chatMessage.message = chatMessageContent
            chatMessage.attachments = batch
            
            _ = try await chatService.addMessage(chatObjectId: chatId, message: chatMessage)
        }
        
        if fullMessage.isNotEmpty {
            try await addTextMessage(text: String(fullMessage.prefix(ChatMessageGlobalLimits.textLimit)), chatId: chatId)
        }
        
        if comment.isNotEmpty && !onlyImages {
            try await addTextMessage(text: String(comment.prefix(ChatMessageGlobalLimits.textLimit)), chatId: chatId)
        }
    }
    
    private func addTextMessage(text: String, chatId: String) async throws {
        var chatMessageContent = ChatMessageContent()
        chatMessageContent.text = text
        
        var chatMessage = ChatMessage()
        chatMessage.message = chatMessageContent
        
        _ = try await chatService.addMessage(chatObjectId: chatId, message: chatMessage)
    }
    
    private func createContainer(
        spaceId: String,
        title: String?
    ) async throws -> ObjectDetails {
        
        let noteObject = try await objectActionsService.createObject(
            name: title ?? "",
            typeUniqueKey: .note,
            shouldDeleteEmptyObject: false,
            shouldSelectType: false,
            shouldSelectTemplate: false,
            spaceId: spaceId,
            origin: .sharingExtension,
            templateId: nil
        )
        
        AnytypeAnalytics.instance().logCreateObject(objectType: noteObject.objectType.analyticsType, spaceId: noteObject.spaceId, route: .sharingExtension)
        
        return noteObject
    }
    
    private func createObjectsFromSharedContent(
        spaceId: String,
        content: SharedContent
    ) async throws -> [SharedSavedContentItem] {
        var details = [SharedSavedContentItem]()
        
        for contentItem in content.items {
            switch contentItem {
            case let .text(text):
                details.append(.text(text))
            case let .url(url):
                let objectDetails = try await createBookmarkObject(url: AnytypeURL(url: url), spaceId: spaceId)
                details.append(.bookmark(objectDetails))
            case let .file(url):
                let objectDetails = try await createFileObject(url: url, spaceId: spaceId)
                details.append(.file(objectDetails))
            }
        }
        
        return details
    }
    
    
    private func createBookmarkObject(url: AnytypeURL, spaceId: String) async throws -> ObjectDetails {
        let type = try? objectTypeProvider.objectType(uniqueKey: ObjectTypeUniqueKey.bookmark, spaceId: spaceId)
        
        let newBookmark = try await bookmarkService.createBookmarkObject(
            spaceId: spaceId,
            url: url,
            templateId: type?.defaultTemplateId,
            origin: .sharingExtension
        )
        try await bookmarkService.fetchBookmarkContent(bookmarkId: newBookmark.id, url: url)
        
        AnytypeAnalytics.instance().logCreateObject(
            objectType: newBookmark.objectType.analyticsType,
            spaceId: newBookmark.spaceId,
            route: .sharingExtension
        )
        return newBookmark
    }
    
    private func createFileObject(url: URL, spaceId: String) async throws -> FileDetails {
        let resources = try url.resourceValues(forKeys: [.fileSizeKey])
        let data = FileData(path: url.relativePath, type: .data, sizeInBytes: resources.fileSize, isTemporary: false)
        let details = try await fileService.uploadFileObject(spaceId: spaceId, data: data, origin: .sharingExtension)
        
        AnytypeAnalytics.instance().logCreateObject(
            objectType: details.analyticsType,
            spaceId: details.spaceId,
            route: .sharingExtension
        )
        return details
    }
    
    private func createBlocks(object: ObjectDetails, contentItems: [SharedSavedContentItem]) async throws {
        
        guard contentItems.isNotEmpty else { return }
        
        for item in contentItems {
            switch item {
            case .text(let text):
                try await createTextBlock(text: text, addToObject: object)
            case .bookmark(let objectDetails):
                try await createBookmarkBlock(bookmarkObject: objectDetails, addToObject: object)
            case .file(let fileDetails):
                try await createFileBlock(fileDetails: fileDetails, addToObject: object)
            }
        }
    }
    
    private func createTextBlock(text: String, addToObject: ObjectDetails) async throws {
        let lastBlockInDocument = try await blockService.lastBlockId(from: addToObject.id, spaceId: addToObject.spaceId)
        let newBlockId = try await blockService.add(
            contextId: addToObject.id,
            targetId: lastBlockInDocument,
            info: .emptyText,
            position: .bottom
        )
        _ = try await pasteboardMiddlewareService.pasteText(text, objectId: addToObject.id, context: .selected(blockIds: [newBlockId]))
    }
    
    private func createBookmarkBlock(bookmarkObject: ObjectDetails, addToObject: ObjectDetails) async throws {
        let blockInformation = BlockInformation.bookmark(targetId: bookmarkObject.id)
        let lastBlockInDocument = try await blockService.lastBlockId(from: addToObject.id, spaceId: addToObject.spaceId)
        let blockId = try await blockService.add(
            contextId: addToObject.id,
            targetId: lastBlockInDocument,
            info: blockInformation,
            position: .bottom
        )
        // Fetch for legacy logic
        if let url = bookmarkObject.source {
            try await bookmarkService.fetchBookmark(objectId: addToObject.id, blockID: blockId, url: url)
        }
    }
    
    private func createFileBlock(fileDetails: FileDetails, addToObject: ObjectDetails) async throws {
        let lastBlockInDocument = try await blockService.lastBlockId(from: addToObject.id, spaceId: addToObject.spaceId)
        let blockInformation = BlockInformation.file(fileDetails: fileDetails)
        _ = try await blockService.add(
            contextId: addToObject.id,
            targetId: lastBlockInDocument,
            info: blockInformation,
            position: .bottom
        )
    }
    
    private func linkTo(object linkToObject: ObjectDetails, linkedObjectId: String) async throws {
        if linkToObject.isCollection {
            try await objectActionsService.addObjectsToCollection(
                contextId: linkToObject.id,
                objectIds: [linkedObjectId]
            )
        } else {
            let blockInformation = BlockInformation.emptyLink(targetId: linkedObjectId)
            let lastBlockInDocument = try await blockService.lastBlockId(from: linkToObject.id, spaceId: linkToObject.spaceId)
            _ = try await blockService.add(
                contextId: linkToObject.id,
                targetId: lastBlockInDocument,
                info: blockInformation,
                position: .bottom
            )
            AnytypeAnalytics.instance().logCreateBlock(type: blockInformation.content.type, spaceId: linkToObject.spaceId, route: .sharingExtension)
        }
    }
}
