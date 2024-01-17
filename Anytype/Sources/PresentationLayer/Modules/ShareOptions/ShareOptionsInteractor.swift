import Foundation
import Services
import SharedContentManager

protocol ShareOptionsInteractorProtocol: AnyObject {
    func saveContent(saveOptions: SharedSaveOptions, content: [SharedContent]) async throws
}

final class ShareOptionsInteractor: ShareOptionsInteractorProtocol {
    
    private let listService: BlockListServiceProtocol
    private let bookmarkService: BookmarkServiceProtocol
    private let objectActionsService: ObjectActionsServiceProtocol
    private let blockActionService: BlockActionsServiceSingleProtocol
    private let pageRepository: PageRepositoryProtocol
    private let fileService: FileActionsServiceProtocol
    private let documentProvider: DocumentsProviderProtocol
    
    init(
        listService: BlockListServiceProtocol,
        bookmarkService: BookmarkServiceProtocol,
        objectActionsService: ObjectActionsServiceProtocol,
        blockActionService: BlockActionsServiceSingleProtocol,
        pageRepository: PageRepositoryProtocol,
        fileService: FileActionsServiceProtocol,
        documentProvider: DocumentsProviderProtocol
    ) {
        self.listService = listService
        self.bookmarkService = bookmarkService
        self.objectActionsService = objectActionsService
        self.blockActionService = blockActionService
        self.pageRepository = pageRepository
        self.fileService = fileService
        self.documentProvider = documentProvider
    }
    
    func saveContent(saveOptions: SharedSaveOptions, content: [SharedContent]) async throws {
        switch saveOptions {
        case .newObject(let spaceId, let linkToObject):
            await saveNewObject(spaceId: spaceId, linkToObject: linkToObject, content: content)
        case .blocks(let spaceId, let addToObject):
            await saveNewBlock(spaceId: spaceId, addToObject: addToObject, content: content)
        }
    }
    
    // MARK: - Private
    
    private func saveNewObject(spaceId: String, linkToObject: ObjectDetails?, content: [SharedContent]) async {
        for contentItem in content {
            do {
                
                let newObjectId: String
                let blockInformation: BlockInformation
                
                switch contentItem {
                case let .text(text):
                    let attributedText = NSAttributedString(text)
                    newObjectId = try await createNoteObject(text: attributedText, spaceId: spaceId).id
                    blockInformation = attributedText.blockInformation
                case let .url(url):
                    newObjectId = try await createBookmarkObject(url: url, spaceId: spaceId).id
                    blockInformation = BlockInformation.bookmark(targetId: newObjectId)
                case let .file(url):
                    newObjectId = try await fileService.uploadFileObject(spaceId: spaceId, data: FileData(path: url.relativePath, isTemporary: false))
                    let fileDocument = documentProvider.document(objectId: newObjectId, forPreview: true)
                    try await fileDocument.openForPreview()
                    guard let fileDetails = fileDocument.details else { continue }
                    blockInformation = BlockInformation.file(fileDetails: fileDetails)
                }
                
                if let linkToObject {
                    if linkToObject.isCollection {
                        try await objectActionsService
                            .addObjectsToCollection(
                                contextId: linkToObject.id,
                                objectIds: [newObjectId]
                            )
                    } else {
                        let lastBlockInDocument = try await listService.lastBlockId(from: linkToObject.id)
                        _ = try await blockActionService.add(
                            contextId: linkToObject.id,
                            targetId: lastBlockInDocument,
                            info: blockInformation,
                            position: .bottom
                        )
                        AnytypeAnalytics.instance().logCreateBlock(type: blockInformation.content.type, route: .sharingExtension)
                    }
                }
            } catch {}
        }
    }
    
    private func saveNewBlock(spaceId: String, addToObject: ObjectDetails, content: [SharedContent]) async {
        for contentItem in content {
            do {
                
                let attributedText: NSAttributedString
                
                switch contentItem {
                case let .text(text):
                    attributedText = NSAttributedString(text)
                case let .url(url):
                    attributedText = url.attributedString
                case let .file(url):
                    continue
                }
                
                let blockInformation = attributedText.blockInformation
                let lastBlockInDocument = try await listService.lastBlockId(from: addToObject.id)
                _ = try await blockActionService.add(
                    contextId: addToObject.id,
                    targetId: lastBlockInDocument,
                    info: blockInformation,
                    position: .bottom
                )
                AnytypeAnalytics.instance().logCreateBlock(type: blockInformation.content.type, route: .sharingExtension)
            } catch {}
        }
    }
    
    private func createBookmarkObject(url: URL, spaceId: BlockId) async throws -> ObjectDetails {
        let newBookmark = try await bookmarkService.createBookmarkObject(
            spaceId: spaceId,
            url: url.absoluteString,
            origin: .sharingExtension
        )
        try await bookmarkService.fetchBookmarkContent(bookmarkId: newBookmark.id, url: url.absoluteString)
        
        AnytypeAnalytics.instance().logCreateObject(
            objectType: .object(typeId: ObjectTypeUniqueKey.bookmark.value),
            route: .sharingExtension
        )
        return newBookmark
    }

    private func createNoteObject(text: NSAttributedString, spaceId: BlockId) async throws -> ObjectDetails {
        let newObject = try await pageRepository.createPage(
            name: "", // TODO: Check it
            typeUniqueKey: .note,
            shouldDeleteEmptyObject: false,
            shouldSelectType: false,
            shouldSelectTemplate: false,
            spaceId: spaceId,
            origin: .sharingExtension,
            templateId: nil
        )
        let lastBlockInDocument = try await listService.lastBlockId(from: newObject.id)
        let blockInformation = text.blockInformation
        _ = try await blockActionService.add(
            contextId: newObject.id,
            targetId: lastBlockInDocument,
            info: blockInformation,
            position: .bottom
        )
        
        AnytypeAnalytics.instance().logCreateObject(
            objectType: .object(typeId: ObjectTypeUniqueKey.note.value),
            route: .sharingExtension
        )
        return newObject
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
