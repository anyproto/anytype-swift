import SwiftUI
import SharedContentManager
import Services
import AnytypeCore
import Factory

protocol SharingExtensionActionServiceProtocol: AnyObject, Sendable {
    func saveObjects(
        spaceId: String,
        content: SharedContent,
        linkToObjects: [ObjectDetails],
        chatId: String?
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
    
    func saveObjects(
        spaceId: String,
        content: SharedContent,
        linkToObjects: [ObjectDetails],
        chatId: String?
    ) async throws {
        await objectTypeProvider.prepareData(spaceId: spaceId)
        
        // Create objects for media & bookmarks
        let contentItems = try await createObjectsFromSharedContent(spaceId: spaceId, content: content)
        
        try await linkToObjectFlow(spaceId: spaceId, content: content, savedContent: contentItems, linkToObjects: linkToObjects)
        
        // TODO: Implement save to chat
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
