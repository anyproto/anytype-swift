import Foundation
import Services
import SharedContentManager
import AnytypeCore


protocol ShareOptionsInteractorProtocol: AnyObject {
    func saveContent(saveOptions: SharedSaveOptions, content: SharedContent) async throws
}

final class ShareOptionsInteractor: ShareOptionsInteractorProtocol {
    
    @Injected(\.blockService)
    private var blockService: BlockServiceProtocol
    @Injected(\.bookmarkService)
    private var bookmarkService: BookmarkServiceProtocol
    @Injected(\.objectActionsService)
    private var objectActionsService: ObjectActionsServiceProtocol
    @Injected(\.fileActionsService)
    private var fileService: FileActionsServiceProtocol
    @Injected(\.documentsProvider)
    private var documentProvider: DocumentsProviderProtocol
    @Injected(\.pasteboardMiddleService)
    private var pasteboardMiddlewareService: PasteboardMiddlewareServiceProtocol
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: ObjectTypeProviderProtocol
    
    func saveContent(saveOptions: SharedSaveOptions, content: SharedContent) async throws {
        switch saveOptions {
        case .container(let spaceId, let linkToObject):
            try await saveNewContainer(spaceId: spaceId, linkToObject: linkToObject, content: content)
        case .newObject(let spaceId, let linkToObject):
            await saveNewObject(spaceId: spaceId, linkToObject: linkToObject, content: content)
        case .blocks(let spaceId, let addToObject):
            await saveNewBlock(spaceId: spaceId, addToObject: addToObject, content: content, logAnalytics: true)
        }
    }
    
    // MARK: - Private
    
    private func saveNewContainer(spaceId: String, linkToObject: ObjectDetails?, content: SharedContent) async throws {
        let noteObject = try await objectActionsService.createObject(
            name: content.title ?? "",
            typeUniqueKey: .note,
            shouldDeleteEmptyObject: false,
            shouldSelectType: false,
            shouldSelectTemplate: false,
            spaceId: spaceId,
            origin: .sharingExtension,
            templateId: nil
        )
        await saveNewBlock(spaceId: spaceId, addToObject: noteObject, content: content, logAnalytics: false)
        if let linkToObject {
            try await linkTo(object: linkToObject, newObjectId: noteObject.id, blockInformation: BlockInformation.emptyLink(targetId: noteObject.id))
        }
        AnytypeAnalytics.instance().logCreateObject(objectType: noteObject.objectType.analyticsType, spaceId: noteObject.spaceId, route: .sharingExtension)
    }
    
    private func saveNewObject(spaceId: String, linkToObject: ObjectDetails?, content: SharedContent) async {
        for contentItem in content.items {
            do {
                
                let newObjectId: String
                let blockInformation: BlockInformation
                
                switch contentItem {
                case let .text(text):
                    newObjectId = try await createNoteObject(text: text, spaceId: spaceId).id
                    blockInformation = BlockInformation.emptyLink(targetId: newObjectId)
                case let .url(url):
                    newObjectId = try await createBookmarkObject(url: AnytypeURL(url: url), spaceId: spaceId).id
                    blockInformation = BlockInformation.bookmark(targetId: newObjectId)
                case let .file(url):
                    newObjectId = try await createFileObject(url: url, spaceId: spaceId).id
                    blockInformation = BlockInformation.emptyLink(targetId: newObjectId)
                }
                
                if let linkToObject {
                    try await linkTo(object: linkToObject, newObjectId: newObjectId, blockInformation: blockInformation)
                }
            } catch {}
        }
    }
    
    private func saveNewBlock(spaceId: String, addToObject: ObjectDetails, content: SharedContent, logAnalytics: Bool) async {
        for contentItem in content.items {
            do {
                switch contentItem {
                case let .text(text):
                    try await createTextBlock(text: text, addToObject: addToObject, logAnalytics: logAnalytics)
                case let .url(url):
                    try await createBookmarkBlock(url: url, addToObject: addToObject, logAnalytics: logAnalytics)
                case let .file(url):
                    try await createFileBlock(fileURL: url, addToObject: addToObject, logAnalytics: logAnalytics)
                }
            } catch {}
        }
    }
    
    private func createBookmarkObject(url: AnytypeURL, spaceId: String) async throws -> ObjectDetails {
        let newBookmark = try await bookmarkService.createBookmarkObject(
            spaceId: spaceId,
            url: url,
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

    private func createNoteObject(text: String, spaceId: String) async throws -> ObjectDetails {
        let newObject = try await objectActionsService.createObject(
            name: "",
            typeUniqueKey: .note,
            shouldDeleteEmptyObject: false,
            shouldSelectType: false,
            shouldSelectTemplate: false,
            spaceId: spaceId,
            origin: .sharingExtension,
            templateId: nil
        )
        let lastBlockInDocument = try await blockService.lastBlockId(from: newObject.id)
        _ = try await pasteboardMiddlewareService.pasteText(text, objectId: newObject.id, context: .selected(blockIds: [lastBlockInDocument]))
        
        AnytypeAnalytics.instance().logCreateObject(
            objectType: newObject.objectType.analyticsType,
            spaceId: newObject.spaceId,
            route: .sharingExtension
        )
        return newObject
    }
    
    private func createFileObject(url: URL, spaceId: String) async throws -> FileDetails {
        let data = FileData(path: url.relativePath, isTemporary: false)
        let details = try await fileService.uploadFileObject(spaceId: spaceId, data: data, origin: .sharingExtension)
        
        AnytypeAnalytics.instance().logCreateObject(
            objectType: details.analyticsType,
            spaceId: details.spaceId,
            route: .sharingExtension
        )
        return details
    }
    
    private func createTextBlock(text: String, addToObject: ObjectDetails, logAnalytics: Bool) async throws {
        let lastBlockInDocument = try await blockService.lastBlockId(from: addToObject.id)
        let newBlockId = try await blockService.add(
            contextId: addToObject.id,
            targetId: lastBlockInDocument,
            info: .emptyText,
            position: .bottom
        )
        _ = try await pasteboardMiddlewareService.pasteText(text, objectId: addToObject.id, context: .selected(blockIds: [newBlockId]))
        if logAnalytics {
            AnytypeAnalytics.instance().logCreateBlock(type: BlockInformation.emptyText.content.type, spaceId: addToObject.spaceId, route: .sharingExtension)
        }
    }
    
    private func createBookmarkBlock(url: URL, addToObject: ObjectDetails, logAnalytics: Bool) async throws {
        let blockInformation = url.attributedString.blockInformation
        let lastBlockInDocument = try await blockService.lastBlockId(from: addToObject.id)
        _ = try await blockService.add(
            contextId: addToObject.id,
            targetId: lastBlockInDocument,
            info: blockInformation,
            position: .bottom
        )
        if logAnalytics {
            AnytypeAnalytics.instance().logCreateBlock(type: blockInformation.content.type, spaceId: addToObject.spaceId, route: .sharingExtension)
        }
    }
    
    private func createFileBlock(fileURL: URL, addToObject: ObjectDetails, logAnalytics: Bool) async throws {
        let lastBlockInDocument = try await blockService.lastBlockId(from: addToObject.id)
        let fileDetails = try await fileService.uploadFileObject(
            spaceId: addToObject.spaceId,
            data: FileData(path: fileURL.relativePath, isTemporary: false),
            origin: .sharingExtension
        )
        let blockInformation = BlockInformation.file(fileDetails: fileDetails)
        _ = try await blockService.add(
            contextId: addToObject.id,
            targetId: lastBlockInDocument,
            info: blockInformation,
            position: .bottom
        )
        if logAnalytics {
            AnytypeAnalytics.instance().logCreateBlock(type: blockInformation.content.type, spaceId: addToObject.spaceId, route: .sharingExtension)
        }
    }
    
    private func linkTo(object linkToObject: ObjectDetails, newObjectId: String, blockInformation: BlockInformation) async throws {
        if linkToObject.isCollection {
            try await objectActionsService
                .addObjectsToCollection(
                    contextId: linkToObject.id,
                    objectIds: [newObjectId]
                )
        } else {
            let lastBlockInDocument = try await blockService.lastBlockId(from: linkToObject.id)
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

private extension NSAttributedString {
    var blockInformation: BlockInformation {
        let middlewareString = AttributedTextConverter.asMiddleware(attributedText: self)
        return BlockInformation.empty(
            content: .text(
                .init(
                    text: middlewareString.text,
                    marks: middlewareString.marks,
                    color: nil,
                    contentType: .text,
                    checked: false,
                    iconEmoji: "",
                    iconImage: ""
                )
            )
        )
    }
}
