import Services
import Foundation
import AnytypeCore

protocol SharedContentInteractorProtocol {
    func saveContent(saveOption: SharedContentSaveOption) async throws
}

private enum SharedContentProccessError: Error {
    case unavailableOptionSelected
}

final class SharedContentInteractor: SharedContentInteractorProtocol {
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
    
    func saveContent(saveOption: SharedContentSaveOption) async throws {
        switch saveOption {
        case .unavailable:
            throw SharedContentProccessError.unavailableOptionSelected
        case .url(let url, let savingOption):
            try await saveURL(url: url, option: savingOption)
        case .text(let string, let destination):
            try await saveText(text: NSAttributedString(attributedString: string), destination: destination)
        }
    }
    
    
    private func saveURL(url: URL, option: SharedContentSaveOption.URLSavingOption) async throws {
        switch option {
        case .bookmark(let destination):
            switch destination {
            case .asObject:
                let _ = try await createBookmarkObject(url: url)
            case .target(let objectDetails):
                if case .collection = objectDetails.layoutValue {
                    let newBookmark = try await createBookmarkObject(url: url)
                    try await objectActionsService.addObjectsToCollection(contextId: objectDetails.id, objectIds: [newBookmark.id])
                } else {
                    let lastBlockInDocument = try await listService.lastBlockId(from: objectDetails.id)
                    try await bookmarkService.createAndFetchBookmark(
                        contextID: objectDetails.id,
                        targetID: lastBlockInDocument,
                        position: .bottom,
                        url: url.absoluteString
                    )
                }
            }
        case .text(let target):
            try await saveText(text: url.attributedString, destination: .textBlock(target))
        }
    }
    
    private func createBookmarkObject(url: URL) async throws -> ObjectDetails {
        let newBookmark = try await bookmarkService.createBookmarkObject(url: url.absoluteString)
        try await bookmarkService.fetchBookmarkContent(bookmarkId: newBookmark.id, url: url.absoluteString)
        
        return newBookmark
    }
    
    private func saveText(text: NSAttributedString, destination: SharedContentSaveOption.TextDestinationOption) async throws {
        switch destination {
        case let .object(named, linkedTo):
            let newObject = try await pageRepository.createPage(
                name: named ?? "",
                type: ObjectTypeId.BundledTypeId.note.rawValue,
                shouldDeleteEmptyObject: false,
                shouldSelectType: false,
                shouldSelectTemplate: false,
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
            
            guard let linkedTo = linkedTo else {
                return
            }
            if linkedTo.isCollection {
                try await objectActionsService.addObjectsToCollection(
                    contextId: linkedTo.id,
                    objectIds: [newObject.id]
                )
            } else {
                let info = BlockInformation.emptyLink(targetId: newObject.id)
                let lastBlockInDocument = try await listService.lastBlockId(from: linkedTo.id)
                let _ = try await blockActionService.add(
                    contextId: linkedTo.id,
                    targetId: lastBlockInDocument,
                    info: info,
                    position: .bottom
                )
            }
        case .textBlock(let objectDetails):
            let blockInformation = text.blockInformation
            let lastBlockInDocument = try await listService.lastBlockId(from: objectDetails.id)
            _ = try await blockActionService.add(
                contextId: objectDetails.id,
                targetId: lastBlockInDocument,
                info: blockInformation,
                position: .bottom
            )
        }
    }
}


extension URL {
    var attributedString: NSAttributedString {
        let mutableAttributedString = NSMutableAttributedString(string: absoluteString)
        let newRange = mutableAttributedString.wholeRange
        let modifier = MarkStyleModifier(
            attributedString: mutableAttributedString,
            anytypeFont: .uxBodyRegular
        )
        modifier.apply(.link(self), shouldApplyMarkup: true, range: newRange)
        
        return NSAttributedString(attributedString: modifier.attributedString)
    }
}

extension NSAttributedString {
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
