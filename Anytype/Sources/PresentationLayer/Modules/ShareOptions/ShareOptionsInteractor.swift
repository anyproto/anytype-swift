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
    
    init(
        listService: BlockListServiceProtocol,
        bookmarkService: BookmarkServiceProtocol,
        objectActionsService: ObjectActionsServiceProtocol,
        blockActionService: BlockActionsServiceSingleProtocol,
        pageRepository: PageRepositoryProtocol
    ) {
        self.listService = listService
        self.bookmarkService = bookmarkService
        self.objectActionsService = objectActionsService
        self.blockActionService = blockActionService
        self.pageRepository = pageRepository
    }
    
    func saveContent(saveOptions: SharedSaveOptions, content: [SharedContent]) async throws {
        switch saveOptions {
        case .newObject(let spaceId, let linkToObjectId):
            await saveNewObject(spaceId: spaceId, linkToObjectId: linkToObjectId, content: content)
        case .blocks(let spaceId, let addToObjectId):
            break
        }
    }
    
    private func saveNewObject(spaceId: String, linkToObjectId: String?, content: [SharedContent]) async {
        for contentItem in content {
            switch contentItem {
            case let .text(text):
                do {
                    let details = try await createNoteObject(text: NSAttributedString(text), spaceId: spaceId)
                } catch {}
            case let .url(url):
                do {
                    let details = try await createBookmarkObject(url: url, spaceId: spaceId)
                    // Link to
                } catch {}
            case let .image(url):
                break
            }
        }
    }
    
//    private func saveURL(
//        url: URL,
//        option: SharedContentSaveOption.SpaceDestination<SharedContentSaveOption.URLSavingOption>
//    ) async throws {
//        switch option {
//        case .space(let space, let saveOption):
//            switch saveOption {
//            case .bookmark(let destination):
//                switch destination {
//                case .asObject:
//                    let _ = try await createBookmarkObject(url: url, spaceId: space.targetSpaceId)
//                case .target(let objectDetails):
//                    if case .collection = objectDetails.layoutValue {
//                        let newBookmark = try await createBookmarkObject(url: url, spaceId: space.targetSpaceId)
//                        try await objectActionsService.addObjectsToCollection(contextId: objectDetails.id, objectIds: [newBookmark.id])
//                    } else {
//                        let lastBlockInDocument = try await listService.lastBlockId(from: objectDetails.id)
//                        let bookmarkObject = try await createBookmarkObject(url: url, spaceId: space.targetSpaceId)
//                        let bookmarkBlock = BlockInformation.bookmark(targetId: bookmarkObject.id)
//                        _ = try await blockActionService.add(
//                            contextId: objectDetails.id,
//                            targetId: lastBlockInDocument,
//                            info: bookmarkBlock,
//                            position: .bottom
//                        )
//                        AnytypeAnalytics.instance().logCreateBlock(type: .bookmark(.text), route: .sharingExtension)
//                    }
//                }
//            case .text(let target):
//                try await saveText(
//                    text: url.attributedString,
//                    destination: .space(space: space, destination: .textBlock(target))
//                )
//            }
//        }
//    }
    
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
    
//    private func saveText(
//        text: NSAttributedString,
//        destination: SharedContentSaveOption.SpaceDestination<SharedContentSaveOption.TextDestinationOption>
//    ) async throws {
//        switch destination {
//        case .space(let space, let option):
//            switch option {
//            case let .object(named, linkedTo):
//                let newObject = try await pageRepository.createPage(
//                    name: named ?? "",
//                    typeUniqueKey: .note,
//                    shouldDeleteEmptyObject: false,
//                    shouldSelectType: false,
//                    shouldSelectTemplate: false,
//                    spaceId: space.targetSpaceId,
//                    origin: .sharingExtension,
//                    templateId: nil
//                )
//                let lastBlockInDocument = try await listService.lastBlockId(from: newObject.id)
//                let blockInformation = text.blockInformation
//                _ = try await blockActionService.add(
//                    contextId: newObject.id,
//                    targetId: lastBlockInDocument,
//                    info: blockInformation,
//                    position: .bottom
//                )
//                
//                guard let linkedTo = linkedTo else {
//                    return
//                }
//                if linkedTo.isCollection {
//                    try await objectActionsService.addObjectsToCollection(
//                        contextId: linkedTo.id,
//                        objectIds: [newObject.id]
//                    )
//                } else {
//                    let info = BlockInformation.emptyLink(targetId: newObject.id)
//                    let lastBlockInDocument = try await listService.lastBlockId(from: linkedTo.id)
//                    let _ = try await blockActionService.add(
//                        contextId: linkedTo.id,
//                        targetId: lastBlockInDocument,
//                        info: info,
//                        position: .bottom
//                    )
//                }
//                AnytypeAnalytics.instance().logCreateObject(
//                    objectType: .object(typeId: ObjectTypeUniqueKey.note.value),
//                    route: .sharingExtension
//                )
//            case .textBlock(let objectDetails):
//                let blockInformation = text.blockInformation
//                let lastBlockInDocument = try await listService.lastBlockId(from: objectDetails.id)
//                _ = try await blockActionService.add(
//                    contextId: objectDetails.id,
//                    targetId: lastBlockInDocument,
//                    info: blockInformation,
//                    position: .bottom
//                )
//                AnytypeAnalytics.instance().logCreateBlock(type: .text(.text), route: .sharingExtension)
//            }
//        }
//    }
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
