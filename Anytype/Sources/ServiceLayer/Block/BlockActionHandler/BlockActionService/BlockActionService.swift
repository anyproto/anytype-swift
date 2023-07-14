import Combine
import Services
import UIKit
import Logger
import ProtobufMessages
import AnytypeCore

final class BlockActionService: BlockActionServiceProtocol {
    private let documentId: BlockId

    private let singleService: BlockActionsServiceSingleProtocol
    private let objectActionService: ObjectActionsServiceProtocol
    private let textService = TextService()
    private let listService: BlockListServiceProtocol
    private let bookmarkService: BookmarkServiceProtocol
    private let fileService = FileActionsService()
    private let cursorManager: EditorCursorManager
    
    private weak var modelsHolder: EditorMainItemModelsHolder?

    init(
        documentId: String,
        listService: BlockListServiceProtocol,
        singleService: BlockActionsServiceSingleProtocol,
        objectActionService: ObjectActionsServiceProtocol,
        modelsHolder: EditorMainItemModelsHolder,
        bookmarkService: BookmarkServiceProtocol,
        cursorManager: EditorCursorManager
    ) {
        self.documentId = documentId
        self.listService = listService
        self.singleService = singleService
        self.objectActionService = objectActionService
        self.modelsHolder = modelsHolder
        self.bookmarkService = bookmarkService
        self.cursorManager = cursorManager
    }

    // MARK: Actions

    func addChild(info: BlockInformation, parentId: BlockId) {
        add(info: info, targetBlockId: parentId, position: .inner)
    }

    func add(info: BlockInformation, targetBlockId: BlockId, position: BlockPosition, setFocus: Bool) {
        AnytypeAnalytics.instance().logCreateBlock(type: info.content.description, style: info.content.type.style)
        Task {
            guard let blockId = try await singleService
                .add(contextId: documentId, targetId: targetBlockId, info: info, position: position) else { return }
            
            if setFocus {
                cursorManager.blockFocus = .init(id: blockId, position: .beginning)
            }
        }
    }

    func split(
        _ string: NSAttributedString,
        blockId: BlockId,
        mode: Anytype_Rpc.Block.Split.Request.Mode,
        range: NSRange,
        newBlockContentType: BlockText.Style
    ) {
        Task {
            let blockId = try await textService.split(
                contextId: documentId,
                blockId: blockId,
                range: range,
                style: newBlockContentType,
                mode: mode
            )
            
            cursorManager.blockFocus = .init(id: blockId, position: .beginning)
        }
    }

    func duplicate(blockId: BlockId) {
        Task {
            try await singleService.duplicate(
                contextId: documentId,
                targetId: blockId,
                blockIds: [blockId],
                position: .bottom
            )
        }
    }

    func createPage(targetId: BlockId, type: ObjectTypeId, position: BlockPosition) async throws -> BlockId {
        try await objectActionService.createPage(
            contextId: documentId,
            targetId: targetId,
            details: [.name(""), .type(type)],
            position: position,
            templateId: ""
        )
    }

    func turnInto(_ style: BlockText.Style, blockId: BlockId) {
        Task {
            try await textService.setStyle(contextId: documentId, blockId: blockId, style: style)
        }
    }
    
    func turnIntoPage(blockId: BlockId) async throws -> BlockId? {
        try await objectActionService.convertChildrenToPages(
            contextID: documentId,
            blocksIds: [blockId],
            typeId: ObjectTypeId.BundledTypeId.page.rawValue
        ).first
    }
    
    func checked(blockId: BlockId, newValue: Bool) {
        Task {
            try await textService.checked(contextId: documentId, blockId: blockId, newValue: newValue)
        }
    }
    
    func merge(secondBlockId: BlockId) {
        Task { @MainActor [weak self, documentId] in
            guard
                let previousBlock = self?.modelsHolder?.findModel(
                    beforeBlockId: secondBlockId,
                    acceptingTypes: BlockContentType.allTextTypes
                ),
                previousBlock.content != .unsupported
            else {
                self?.delete(blockIds: [secondBlockId])
                return
            }
            do {
                try await self?.textService.merge(contextId: documentId, firstBlockId: previousBlock.blockId, secondBlockId: secondBlockId)
                self?.setFocus(model: previousBlock)
            } catch {
                // Do not set focus to previous block
            }
        }
    }
    
    func delete(blockIds: [BlockId]) {
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.blockDelete)
        Task {
            try await singleService.delete(contextId: documentId, blockIds: blockIds)
        }
    }
    
    func setText(contextId: BlockId, blockId: BlockId, middlewareString: MiddlewareString) async throws {
        try await textService.setText(contextId: contextId, blockId: blockId, middlewareString: middlewareString)
    }

    func setTextForced(contextId: BlockId, blockId: BlockId, middlewareString: MiddlewareString) async throws {
        try await textService.setTextForced(contextId: contextId, blockId: blockId, middlewareString: middlewareString)
    }
    
    func setObjectTypeId(_ objectTypeId: String) async throws {
        try await objectActionService.setObjectType(objectId: documentId, objectTypeId: objectTypeId)
    }

    func setObjectSetType() async throws {
        try await objectActionService.setObjectSetType(objectId: documentId)
    }
    
    func setObjectCollectionType() async throws {
        try await objectActionService.setObjectCollectionType(objectId: documentId)
    }

    private func setFocus(model: BlockViewModelProtocol) {
        if case let .text(text) = model.info.content {
            model.set(focus: .at(text.endOfTextRangeWithMention))
        }
    }
}

// MARK: - BookmarkFetch

extension BlockActionService {
    func bookmarkFetch(blockId: BlockId, url: AnytypeURL) {
        Task {
            try await bookmarkService.fetchBookmark(contextID: documentId, blockID: blockId, url: url.absoluteString)
        }
    }

    func createAndFetchBookmark(
        contextID: BlockId,
        targetID: BlockId,
        position: BlockPosition,
        url: AnytypeURL
    ) {
        Task {
            try await bookmarkService.createAndFetchBookmark(
                contextID: contextID,
                targetID: targetID,
                position: position,
                url: url.absoluteString
            )
        }
    }
}

// MARK: - SetBackgroundColor

extension BlockActionService {
    func setBackgroundColor(blockIds: [BlockId], color: BlockBackgroundColor) {
        setBackgroundColor(blockIds: blockIds, color: color.middleware)
    }
    
    func setBackgroundColor(blockIds: [BlockId], color: MiddlewareColor) {
        Task {
            try await listService.setBackgroundColor(objectId: documentId, blockIds: blockIds, color: color)
        }
    }
}

// MARK: - UploadFile

extension BlockActionService {
    func upload(blockId: BlockId, filePath: String) async throws {
        try await fileService.uploadDataAt(source: .path(filePath), contextID: documentId, blockID: blockId)
    }
}
