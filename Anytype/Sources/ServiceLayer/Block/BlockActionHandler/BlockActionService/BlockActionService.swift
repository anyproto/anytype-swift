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
    private let listService = BlockListService()
    private let bookmarkService = BookmarkService()
    private let fileService = BlockActionsServiceFile()
    private let cursorManager: EditorCursorManager
    
    private weak var modelsHolder: BlockViewModelsHolder?

    init(
        documentId: String,
        modelsHolder: BlockViewModelsHolder,
        cursorManager: EditorCursorManager
    ) {
        self.documentId = documentId
        self.modelsHolder = modelsHolder
        self.cursorManager = cursorManager
    }

    // MARK: Actions/Add

    func addChild(info: BlockInformation, parentId: BlockId) {
        add(info: info, targetBlockId: parentId, position: .inner, shouldSetFocusOnUpdate: true)
    }

    func add(info: BlockInformation, targetBlockId: BlockId, position: BlockPosition, shouldSetFocusOnUpdate: Bool) {
        guard let response = singleService
                .add(contextId: documentId, targetId: targetBlockId, info: info, position: position) else { return }

        if shouldSetFocusOnUpdate,
           let addEntryMessage = response.messages.first { $0.value == .blockAdd($0.blockAdd) },
            let block = addEntryMessage.blockAdd.blocks.first {
                cursorManager.blockFocus = .init(id: block.id, position: .beginning)
            }

        response.asEventsBunch.send()
    }

    func split(
        info: BlockInformation,
        position: Int,
        newBlockContentType: BlockText.Style,
        attributedString: NSAttributedString
    ) {
        let blockId = info.id

        let range = NSRange(location: position, length: 0)
        let documentId = self.documentId
        
        // if splitted block has child then new block should be child of splitted block
        let mode: Anytype_Rpc.Block.Split.Request.Mode = info.childrenIds.count > 0 ? .inner : .bottom

        textService.setTextForced(
            contextId: documentId,
            blockId: blockId,
            middlewareString: AttributedTextConverter.asMiddleware(attributedText: attributedString)
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
            .duplicate(
                contextId: documentId,
                targetId: blockId,
                blockIds: [blockId],
                position: .bottom
            )
            .flatMap {
                EventsBunch(contextId: documentId, middlewareEvents: $0.messages).send()
            }
    }


    func createPage(targetId: BlockId, type: ObjectTemplateType, position: BlockPosition) -> BlockId? {
        guard let newBlockId = pageService.createPage(
            contextId: documentId,
            targetId: targetId,
            details: [.name(""), .type(type)],
            position: position,
            templateId: ""
        ) else { return nil }

        #warning("replace with CreateObject")
//        Amplitude.instance().logEvent(AmplitudeEventsName.blockCreatePage)

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
            let previousBlock = modelsHolder?.findModel(beforeBlockId: secondBlockId),
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
        let previousBlock = modelsHolder?.findModel(beforeBlockId: blockId)

        if singleService.delete(contextId: documentId, blockIds: [blockId]) {
            previousBlock.map { setFocus(model: $0) }
        }
    }
    
    func setFields(contextID: BlockId, blockFields: [BlockFields]) {
        listService.setFields(contextId: contextID, fields: blockFields)
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
        if case let .text(text) = model.information.content {
            model.set(focus: .at(text.endOfTextRangeWithMention))
        }
    }
}

private extension BlockActionService {

    func setDividerStyle(blockId: BlockId, style: BlockDivider.Style) {
        listService.setDivStyle(contextId: documentId, blockIds: [blockId], style: style)
    }
}

// MARK: - BookmarkFetch

extension BlockActionService {
    func bookmarkFetch(blockId: BlockId, url: String) {
        bookmarkService.fetchBookmark(contextID: self.documentId, blockID: blockId, url: url)
    }
}

// MARK: - SetBackgroundColor

extension BlockActionService {
    func setBackgroundColor(blockId: BlockId, color: BlockBackgroundColor) {
        setBackgroundColor(blockId: blockId, color: color.middleware)
    }
    
    func setBackgroundColor(blockId: BlockId, color: MiddlewareColor) {
        listService.setBackgroundColor(contextId: documentId, blockIds: [blockId], color: color)
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
            .sinkWithDefaultCompletion("fileService.uploadDataAtFilePath", domain: .blockActionsService) { serviceSuccess in
                serviceSuccess.asEventsBunch.send()
        }.store(in: &self.subscriptions)
    }
}
