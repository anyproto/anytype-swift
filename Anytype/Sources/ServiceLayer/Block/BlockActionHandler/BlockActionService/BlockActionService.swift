import Combine
import Services
import UIKit
import Logger
import ProtobufMessages
import AnytypeCore

@MainActor
final class BlockActionService: BlockActionServiceProtocol {
    private let documentId: String
    private let cursorManager: EditorCursorManager

    @Injected(\.objectActionsService)
    private var objectActionService: any ObjectActionsServiceProtocol
    @Injected(\.textServiceHandler)
    private var textServiceHandler: any TextServiceProtocol
    @Injected(\.blockService)
    private var blockService: any BlockServiceProtocol
    @Injected(\.bookmarkService)
    private var bookmarkService: any BookmarkServiceProtocol
    @Injected(\.fileActionsService)
    private var fileService: any FileActionsServiceProtocol
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    
    private weak var modelsHolder: EditorMainItemModelsHolder?

    init(
        documentId: String,
        modelsHolder: EditorMainItemModelsHolder,
        cursorManager: EditorCursorManager
    ) {
        self.documentId = documentId
        self.modelsHolder = modelsHolder
        self.cursorManager = cursorManager
    }

    // MARK: Actions

    func addChild(info: BlockInformation, parentId: String) async throws {
        try await add(info: info, targetBlockId: parentId, position: .inner)
    }

    func add(info: BlockInformation, targetBlockId: String, position: BlockPosition, setFocus: Bool) async throws {
        let blockId = try await blockService.add(contextId: documentId, targetId: targetBlockId, info: info, position: position)
        
        if setFocus {
            cursorManager.blockFocus = BlockFocus(id: blockId, position: .beginning)
        }
    }

    func setAndSplit(
        _ string: SafeNSAttributedString,
        blockId: String,
        mode: Anytype_Rpc.Block.Split.Request.Mode,
        range: NSRange,
        newBlockContentType: BlockText.Style
    ) async throws {
        let middlewareString = AttributedTextConverter.asMiddleware(attributedText: string.value)
        try await textServiceHandler.setText(
            contextId: documentId,
            blockId: blockId,
            middlewareString: middlewareString
        )
        let blockId = try await textServiceHandler.split(
            contextId: documentId,
            blockId: blockId,
            range: range,
            style: newBlockContentType,
            mode: mode
        )

        cursorManager.focus(at: blockId, position: .beginning)
        cursorManager.blockFocus = BlockFocus(id: blockId, position: .beginning)
    }

    func duplicate(blockId: String) {
        Task {
            try await blockService.duplicate(
                contextId: documentId,
                targetId: blockId,
                blockIds: [blockId],
                position: .bottom
            )
        }
    }

    func createPage(targetId: String, spaceId: String, typeUniqueKey: ObjectTypeUniqueKey, position: BlockPosition, templateId: String) async throws -> String {
        try await blockService.createBlockLink(
            contextId: documentId,
            targetId: targetId,
            spaceId: spaceId,
            details: [.name("")],
            typeUniqueKey: typeUniqueKey,
            position: position,
            templateId: templateId
        )
    }

    func turnInto(_ style: BlockText.Style, blockId: String) async throws {
        try await textServiceHandler.setStyle(contextId: documentId, blockId: blockId, style: style)
    }
    
    func turnIntoObject(blockId: String, spaceId: String) async throws -> String? {
        let defaultObjectType = try objectTypeProvider.defaultObjectType(spaceId: spaceId)
        AnytypeAnalytics.instance().logCreateObject(objectType: defaultObjectType.analyticsType, spaceId: spaceId, route: .turnInto)

        return try await blockService.convertChildrenToObjects(
            contextId: documentId,
            blocksIds: [blockId],
            typeUniqueKey: defaultObjectType.uniqueKey,
            templateId: defaultObjectType.defaultTemplateId
        ).first
    }
    
    func checked(blockId: String, newValue: Bool) {
        Task {
            try await textServiceHandler.checked(contextId: documentId, blockId: blockId, newValue: newValue)
        }
    }
    
    func merge(secondBlockId: String) async throws {
        guard
            let previousBlock = modelsHolder?.findModel(
                beforeBlockId: secondBlockId,
                acceptingTypes: BlockContentType.allTextTypes
            ),
            previousBlock.content != .unsupported
        else {
            delete(blockIds: [secondBlockId])
            return
        }

        if let textContent = previousBlock.info.textContent {
            cursorManager.focus(
                at: previousBlock.blockId,
                position: .at(NSRange(location: Int(textContent.text.utf16.count), length: 0))
            )
            cursorManager.blockFocus = BlockFocus(id: previousBlock.blockId, position: .at(NSRange(location: textContent.text.utf16.count, length: 0)))
        }
        try await textServiceHandler.merge(contextId: documentId, firstBlockId: previousBlock.blockId, secondBlockId: secondBlockId)
    }
    
    func delete(blockIds: [String]) {
        AnytypeAnalytics.instance().logDeleteBlock()
        Task {
            try await blockService.delete(contextId: documentId, blockIds: blockIds)
        }
    }
    
    func setText(contextId: String, blockId: String, middlewareString: MiddlewareString) async throws {
        try await textServiceHandler.setText(contextId: contextId, blockId: blockId, middlewareString: middlewareString)
    }

    func setTextForced(contextId: String, blockId: String, middlewareString: MiddlewareString) async throws {
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

    private func setFocus(model: some BlockViewModelProtocol) {
        model.set(focus: .end)
    }
}

// MARK: - BookmarkFetch

extension BlockActionService {
    func bookmarkFetch(blockId: String, url: AnytypeURL) {
        Task {
            try await bookmarkService.fetchBookmark(objectId: documentId, blockID: blockId, url: url)
        }
    }

    func createAndFetchBookmark(
        contextID: String,
        targetID: String,
        position: BlockPosition,
        url: AnytypeURL
    ) {
        Task {
            try await bookmarkService.createAndFetchBookmark(
                objectId: contextID,
                targetID: targetID,
                position: position,
                url: url
            )
        }
    }
}

// MARK: - SetBackgroundColor

extension BlockActionService {
    func setBackgroundColor(blockIds: [String], color: BlockBackgroundColor) {
        setBackgroundColor(blockIds: blockIds, color: color.middleware)
    }
    
    func setBackgroundColor(blockIds: [String], color: MiddlewareColor) {
        Task {
            try await blockService.setBackgroundColor(objectId: documentId, blockIds: blockIds, color: color)
        }
    }
}

// MARK: - UploadFile

extension BlockActionService {
    func upload(blockId: String, filePath: String) async throws {
        try await fileService.uploadDataAt(source: .path(filePath), contextID: documentId, blockID: blockId)
    }
}
