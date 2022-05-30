import Combine
import BlocksModels
import UIKit
import AnytypeCore
import ProtobufMessages


extension LoggerCategory {
    static let blockActionService: Self = "blockActionService"
}

final class BlockActionService: BlockActionServiceProtocol {
    private let documentId: BlockId

    private var subscriptions: [AnyCancellable] = []
    private let singleService: BlockActionsServiceSingleProtocol
    private let pageService = ServiceLocator.shared.objectActionsService()
    private let textService = TextService()
    private let listService: BlockListServiceProtocol
    private let bookmarkService = BookmarkService()
    private let fileService = FileActionsService()
    private let cursorManager: EditorCursorManager
    
    private weak var modelsHolder: EditorMainItemModelsHolder?

    init(
        documentId: String,
        listService: BlockListServiceProtocol,
        singleService: BlockActionsServiceSingleProtocol,
        modelsHolder: EditorMainItemModelsHolder,
        cursorManager: EditorCursorManager
    ) {
        self.documentId = documentId
        self.listService = listService
        self.singleService = singleService
        self.modelsHolder = modelsHolder
        self.cursorManager = cursorManager
    }

    // MARK: Actions

    func addChild(info: BlockInformation, parentId: BlockId) {
        add(info: info, targetBlockId: parentId, position: .inner)
    }

    func add(info: BlockInformation, targetBlockId: BlockId, position: BlockPosition, setFocus: Bool) {
        guard let blockId = singleService
                .add(targetId: targetBlockId, info: info, position: position) else { return }
        
        if setFocus {
            cursorManager.blockFocus = .init(id: blockId, position: .beginning)
        }
    }

    func split(
        _ string: NSAttributedString,
        blockId: BlockId,
        mode: Anytype_Rpc.Block.Split.Request.Mode,
        range: NSRange,
        newBlockContentType: BlockText.Style
    ) {
        guard let blockId = textService.split(
            contextId: documentId,
            blockId: blockId,
            range: range,
            style: newBlockContentType,
            mode: mode
        ) else { return }

        cursorManager.blockFocus = .init(id: blockId, position: .beginning)
    }

    func duplicate(blockId: BlockId) {        
        singleService
            .duplicate(targetId: blockId, blockIds: [blockId], position: .bottom)
    }


    func createPage(targetId: BlockId, type: ObjectTemplateType, position: BlockPosition) -> BlockId? {
        guard let newBlockId = pageService.createPage(
            contextId: documentId,
            targetId: targetId,
            details: [.name(""), .type(type)],
            position: position,
            templateId: ""
        ) else { return nil }

        return newBlockId
    }

    func turnInto(_ style: BlockText.Style, blockId: BlockId) {
        textService.setStyle(contextId: documentId, blockId: blockId, style: style)
    }
    
    func turnIntoPage(blockId: BlockId) -> BlockId? {
        return pageService
            .convertChildrenToPages(contextID: documentId, blocksIds: [blockId], objectType: "")?
            .first
    }
    
    func checked(blockId: BlockId, newValue: Bool) {
        textService.checked(contextId: documentId, blockId: blockId, newValue: newValue)
    }
    
    func merge(secondBlockId: BlockId) {
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
        
        if textService.merge(contextId: documentId, firstBlockId: previousBlock.blockId, secondBlockId: secondBlockId) {
            setFocus(model: previousBlock)
        }
    }
    
    func delete(blockIds: [BlockId]) {
        _ = singleService.delete(blockIds: blockIds)
    }
    
    func setFields(blockFields: BlockFields, blockId: BlockId) {
        let setFieldsRequest = Anytype_Rpc.BlockList.Set.Fields.Request.BlockField(blockID: blockId, fields: .init(fields: blockFields))
        listService.setFields(fields: [setFieldsRequest])
    }
    
    func setText(contextId: BlockId, blockId: BlockId, middlewareString: MiddlewareString) {
        textService.setText(contextId: contextId, blockId: blockId, middlewareString: middlewareString)
    }

    @discardableResult
    func setTextForced(contextId: BlockId, blockId: BlockId, middlewareString: MiddlewareString) -> Bool {
        textService.setTextForced(contextId: contextId, blockId: blockId, middlewareString: middlewareString)
    }
    
    func setObjectTypeUrl(_ objectTypeUrl: String) {
        pageService.setObjectType(objectId: documentId, objectTypeUrl: objectTypeUrl)
    }

    private func setFocus(model: BlockViewModelProtocol) {
        if case let .text(text) = model.info.content {
            model.set(focus: .at(text.endOfTextRangeWithMention))
        }
    }
}

private extension BlockActionService {

    func setDividerStyle(blockId: BlockId, style: BlockDivider.Style) {
        listService.setDivStyle(blockIds: [blockId], style: style)
    }
}

// MARK: - BookmarkFetch

extension BlockActionService {
    func bookmarkFetch(blockId: BlockId, url: String) {
        bookmarkService.fetchBookmark(contextID: self.documentId, blockID: blockId, url: url)
    }

    func createAndFetchBookmark(
        contextID: BlockId,
        targetID: BlockId,
        position: BlockPosition,
        url: String
    ) {
        bookmarkService.createAndFetchBookmark(
            contextID: contextID,
            targetID: targetID,
            position: position,
            url: url
        )
    }
}

// MARK: - SetBackgroundColor

extension BlockActionService {
    func setBackgroundColor(blockId: BlockId, color: BlockBackgroundColor) {
        setBackgroundColor(blockId: blockId, color: color.middleware)
    }
    
    func setBackgroundColor(blockId: BlockId, color: MiddlewareColor) {
        listService.setBackgroundColor(blockIds: [blockId], color: color)
    }
}

// MARK: - UploadFile

extension BlockActionService {
    func upload(blockId: BlockId, filePath: String) {
        fileService.asyncUploadDataAt(
            filePath: filePath,
            contextID: self.documentId,
            blockID: blockId
        )
            .sinkWithDefaultCompletion("fileService.uploadDataAtFilePath", domain: .blockActionsService) { events in
                events.send()
        }.store(in: &self.subscriptions)
    }
}
