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
    private let textServiceHandler: TextServiceProtocol
    private let listService: BlockListServiceProtocol
    private let bookmarkService: BookmarkServiceProtocol
    private let fileService: FileActionsServiceProtocol
    private let cursorManager: EditorCursorManager
    private let objectTypeProvider: ObjectTypeProviderProtocol
    
    private weak var modelsHolder: EditorMainItemModelsHolder?

    init(
        documentId: String,
        listService: BlockListServiceProtocol,
        singleService: BlockActionsServiceSingleProtocol,
        objectActionService: ObjectActionsServiceProtocol,
        textServiceHandler: TextServiceProtocol,
        modelsHolder: EditorMainItemModelsHolder,
        bookmarkService: BookmarkServiceProtocol,
        fileService: FileActionsServiceProtocol,
        cursorManager: EditorCursorManager,
        objectTypeProvider: ObjectTypeProviderProtocol
    ) {
        self.documentId = documentId
        self.listService = listService
        self.singleService = singleService
        self.objectActionService = objectActionService
        self.textServiceHandler = textServiceHandler
        self.modelsHolder = modelsHolder
        self.bookmarkService = bookmarkService
        self.fileService = fileService
        self.cursorManager = cursorManager
        self.objectTypeProvider = objectTypeProvider
    }

    // MARK: Actions

    func addChild(info: BlockInformation, parentId: BlockId) {
        add(info: info, targetBlockId: parentId, position: .inner)
    }

    func add(info: BlockInformation, targetBlockId: BlockId, position: BlockPosition, setFocus: Bool) {
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
            let blockId = try await textServiceHandler.split(
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

    func createPage(targetId: BlockId, spaceId: String, typeUniqueKey: ObjectTypeUniqueKey, position: BlockPosition, templateId: String) async throws -> BlockId {
        try await objectActionService.createPage(
            contextId: documentId,
            targetId: targetId,
            spaceId: spaceId,
            details: [.name("")],
            typeUniqueKey: typeUniqueKey,
            position: position,
            templateId: templateId
        )
    }

    func turnInto(_ style: BlockText.Style, blockId: BlockId) {
        Task {
            try await textServiceHandler.setStyle(contextId: documentId, blockId: blockId, style: style)
        }
    }
    
    func turnIntoPage(blockId: BlockId, spaceId: String) async throws -> BlockId? {
        let pageType = try objectTypeProvider.objectType(uniqueKey: .page, spaceId: spaceId)
        AnytypeAnalytics.instance().logCreateObject(objectType: pageType.analyticsType, route: .turnInto)

        return try await objectActionService.convertChildrenToPages(
            contextID: documentId,
            blocksIds: [blockId],
            typeUniqueKey: pageType.uniqueKey
        ).first
    }
    
    func checked(blockId: BlockId, newValue: Bool) {
        Task {
            try await textServiceHandler.checked(contextId: documentId, blockId: blockId, newValue: newValue)
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
                self?.setFocus(model: previousBlock)
                try await self?.textServiceHandler.merge(contextId: documentId, firstBlockId: previousBlock.blockId, secondBlockId: secondBlockId)
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
        try await textServiceHandler.setText(contextId: contextId, blockId: blockId, middlewareString: middlewareString)
    }

    func setTextForced(contextId: BlockId, blockId: BlockId, middlewareString: MiddlewareString) async throws {
        try await textServiceHandler.setTextForced(contextId: contextId, blockId: blockId, middlewareString: middlewareString)
    }
    
    func setObjectType(type: ObjectType) async throws {
        try await objectActionService.setObjectType(objectId: documentId, typeUniqueKey: type.uniqueKey)
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
