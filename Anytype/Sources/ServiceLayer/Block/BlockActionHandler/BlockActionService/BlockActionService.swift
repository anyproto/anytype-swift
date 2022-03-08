import Combine
import BlocksModels
import UIKit
import Amplitude
import AnytypeCore
import ProtobufMessages


extension LoggerCategory {
    static let blockActionService: Self = "blockActionService"
}

final class BlockActionService: BlockActionServiceProtocol {
    private let documentId: BlockId

    private var subscriptions: [AnyCancellable] = []
    private let singleService = ServiceLocator.shared.blockActionsServiceSingle()
    private let pageService = ObjectActionsService()
    private let textService = TextService()
    private let listService: BlockListServiceProtocol
    private let bookmarkService = BookmarkService()
    private let fileService = BlockActionsServiceFile()
    private let pastboardService = PastboardService()
    private let cursorManager: EditorCursorManager
    
    private weak var modelsHolder: EditorMainItemModelsHolder?

    init(
        documentId: String,
        listService: BlockListServiceProtocol,
        modelsHolder: EditorMainItemModelsHolder,
        cursorManager: EditorCursorManager
    ) {
        self.documentId = documentId
        self.listService = listService
        self.modelsHolder = modelsHolder
        self.cursorManager = cursorManager
    }

    // MARK: Actions

    func paste(blockId: BlockId, range: NSRange) {
        let slots = pastboardService.obtainSlots()
        singleService.paste(contextId: documentId, focusedBlockId: blockId, selectedTextRange: range, isPartOfBlock: false, slots: slots)
    }

    func paste(selectedBlockIds: [BlockId]) {
        let slots = pastboardService.obtainSlots()
        singleService.paste(contextId: documentId, selectedBlockIds: selectedBlockIds, isPartOfBlock: false, slots: slots)
    }

    func addChild(info: BlockInformation, parentId: BlockId) {
        add(info: info, targetBlockId: parentId, position: .inner)
    }

    func add(info: BlockInformation, targetBlockId: BlockId, position: BlockPosition, setFocus: Bool) {
        guard let blockId = singleService
                .add(contextId: documentId, targetId: targetBlockId, info: info, position: position) else { return }
        
        if setFocus {
            cursorManager.blockFocus = .init(id: blockId, position: .beginning)
        }
    }

    func split(
        _ string: NSAttributedString,
        blockId: BlockId,
        mode: Anytype_Rpc.Block.Split.Request.Mode,
        position: Int,
        newBlockContentType: BlockText.Style
    ) {
        let range = NSRange(location: position, length: 0)

        textService.setTextForced(
            contextId: documentId,
            blockId: blockId,
            middlewareString: AttributedTextConverter.asMiddleware(attributedText: string)
        )

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
            .duplicate(contextId: documentId, targetId: blockId, blockIds: [blockId], position: .bottom)
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
            delete(blockId: secondBlockId)
            return
        }
        
        if textService.merge(contextId: documentId, firstBlockId: previousBlock.blockId, secondBlockId: secondBlockId) {
            setFocus(model: previousBlock)
        }
    }
    
    func delete(blockId: BlockId) {
        let previousBlock = modelsHolder?.findModel(
            beforeBlockId: blockId,
            acceptingTypes: BlockContentType.allTextTypes
        )

        if singleService.delete(contextId: documentId, blockIds: [blockId]) {
            previousBlock.map { setFocus(model: $0) }
        }
    }
    
    func setFields(blockFields: [BlockFields]) {
        listService.setFields(fields: blockFields)
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
