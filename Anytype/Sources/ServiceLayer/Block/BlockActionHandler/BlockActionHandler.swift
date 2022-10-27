import UIKit
import BlocksModels
import Combine
import AnytypeCore
import ProtobufMessages

final class BlockActionHandler: BlockActionHandlerProtocol {
    weak var blockSelectionHandler: BlockSelectionHandler?
    private let document: BaseDocumentProtocol
    
    private let service: BlockActionServiceProtocol
    private let listService: BlockListServiceProtocol
    private let markupChanger: BlockMarkupChangerProtocol
    private let keyboardHandler: KeyboardActionHandlerProtocol
    private let blockTableService: BlockTableServiceProtocol
    
    private let fileUploadingDemon = MediaFileUploadingDemon.shared
    
    init(
        document: BaseDocumentProtocol,
        markupChanger: BlockMarkupChangerProtocol,
        service: BlockActionServiceProtocol,
        listService: BlockListServiceProtocol,
        keyboardHandler: KeyboardActionHandlerProtocol,
        blockTableService: BlockTableServiceProtocol
    ) {
        self.document = document
        self.markupChanger = markupChanger
        self.service = service
        self.listService = listService
        self.keyboardHandler = keyboardHandler
        self.blockTableService = blockTableService
    }

    // MARK: - Service proxy

    func turnIntoPage(blockId: BlockId) -> BlockId? {
        return service.turnIntoPage(blockId: blockId)
    }
    
    func turnInto(_ style: BlockText.Style, blockId: BlockId) {
        service.turnInto(style, blockId: blockId)
    }
    
    func upload(blockId: BlockId, filePath: String) {
        service.upload(blockId: blockId, filePath: filePath)
    }
    
    func setObjectTypeUrl(_ objectTypeUrl: String) {
        service.setObjectTypeUrl(objectTypeUrl)
    }

    func setObjectSetType() -> BlockId {
        service.setObjectSetType()
    }
    
    func setTextColor(_ color: BlockColor, blockIds: [BlockId]) {
        listService.setBlockColor(blockIds: blockIds, color: color.middleware)
    }
    
    func setBackgroundColor(_ color: BlockBackgroundColor, blockIds: [BlockId]) {
        service.setBackgroundColor(blockIds: blockIds, color: color)
    }
    
    func duplicate(blockId: BlockId) {
        service.duplicate(blockId: blockId)
    }
    
    func setFields(_ fields: FieldsConvertibleProtocol, blockId: BlockId) {
        guard let info = document.infoContainer.get(id: blockId) else { return }

        let newFields = info.fields.merging(fields.asMiddleware()) { (_, new) in new }

        service.setFields(blockFields: newFields, blockId: blockId)
    }
    
    func fetch(url: AnytypeURL, blockId: BlockId) {
        service.bookmarkFetch(blockId: blockId, url: url)
    }
    
    func checkbox(selected: Bool, blockId: BlockId) {
        service.checked(blockId: blockId, newValue: selected)
    }
    
    func toggle(blockId: BlockId) {
        EventsBunch(contextId: document.objectId, localEvents: [.setToggled(blockId: blockId)])
            .send()
    }
    
    func setAlignment(_ alignment: LayoutAlignment, blockIds: [BlockId]) {
        listService.setAlign(blockIds: blockIds, alignment: alignment)
    }
    
    func delete(blockIds: [BlockId]) {
        service.delete(blockIds: blockIds)
    }
    
    func moveToPage(blockId: BlockId, pageId: BlockId) {
        listService.moveToPage(blockId: blockId, pageId: pageId)
    }
    
    func createEmptyBlock(parentId: BlockId) {
        service.addChild(info: BlockInformation.emptyText, parentId: parentId)
    }
    
    func addLink(targetId: BlockId, typeUrl: String, blockId: BlockId) {
        let isBookmarkType = ObjectTypeUrl.bundled(.bookmark).rawValue == typeUrl
        service.add(
            info: isBookmarkType ? .bookmark(targetId: targetId) : .emptyLink(targetId: targetId),
            targetBlockId: blockId,
            position: .replace
        )
    }
    
    func changeMarkup(blockIds: [BlockId], markType: MarkupType) {
        listService.changeMarkup(blockIds: blockIds, markType: markType)
    }
    
    // MARK: - Markup changer proxy
    func toggleWholeBlockMarkup(_ markup: MarkupType, blockId: BlockId) {
        guard let newText = markupChanger.toggleMarkup(markup, blockId: blockId) else { return }
        
        changeTextForced(newText, blockId: blockId)
    }
    
    func changeTextStyle(_ attribute: MarkupType, range: NSRange, blockId: BlockId) {
        guard let newText = markupChanger.toggleMarkup(attribute, blockId: blockId, range: range) else { return }

        AnytypeAnalytics.instance().logSetMarkup(attribute)

        changeTextForced(newText, blockId: blockId)
    }
    
    func setTextStyle(_ attribute: MarkupType, range: NSRange, blockId: BlockId, currentText: NSAttributedString?) {
        guard let newText = markupChanger.setMarkup(attribute, blockId: blockId, range: range, currentText: currentText)
            else { return }

        AnytypeAnalytics.instance().logSetMarkup(attribute)

        changeTextForced(newText, blockId: blockId)
    }
    
    func setLink(url: URL?, range: NSRange, blockId: BlockId) {
        let newText: NSAttributedString?
        if let url = url {
            AnytypeAnalytics.instance().logSetMarkup(MarkupType.link(url))
            newText = markupChanger.setMarkup(.link(url), blockId: blockId, range: range)
        } else {
            newText = markupChanger.removeMarkup(.link(nil), blockId: blockId, range: range)
        }
        
        guard let newText = newText else { return }
        changeTextForced(newText, blockId: blockId)
    }
    
    func setLinkToObject(linkBlockId: BlockId?, range: NSRange, blockId: BlockId) {
        let newText: NSAttributedString?
        if let linkBlockId = linkBlockId {
            AnytypeAnalytics.instance().logSetMarkup(MarkupType.linkToObject(blockId))
            newText = markupChanger.setMarkup(.linkToObject(linkBlockId), blockId: blockId, range: range)
        } else {
            newText = markupChanger.removeMarkup(.linkToObject(nil), blockId: blockId, range: range)
        }
        
        guard let newText = newText else { return }
        changeTextForced(newText, blockId: blockId)
    }

    func handleKeyboardAction(
        _ action: CustomTextView.KeyboardAction,
        currentText: NSAttributedString,
        info: BlockInformation
    ) {
        keyboardHandler.handle(info: info, currentString: currentText, action: action)
    }
    
    func changeTextForced(_ text: NSAttributedString, blockId: BlockId) {
        guard let info = document.infoContainer.get(id: blockId) else { return }

        guard case .text = info.content else { return }

        let middlewareString = AttributedTextConverter.asMiddleware(attributedText: text)

        EventsBunch(
            contextId: document.objectId,
            localEvents: [.setText(blockId: info.id, text: middlewareString)]
        ).send()

        service.setTextForced(contextId: document.objectId, blockId: info.id, middlewareString: middlewareString)
    }
    
    func changeText(_ text: NSAttributedString, info: BlockInformation) {
        guard case .text = info.content else { return }

        let middlewareString = AttributedTextConverter.asMiddleware(attributedText: text)

        EventsBunch(
            contextId: document.objectId,
            dataSourceUpdateEvents: [.setText(blockId: info.id, text: middlewareString)]
        ).send()

        service.setText(contextId: document.objectId, blockId: info.id, middlewareString: middlewareString)
    }
    
    // MARK: - Public methods
    func uploadMediaFile(uploadingSource: MediaFileUploadingSource, type: MediaPickerContentType, blockId: BlockId) {
        EventsBunch(
            contextId: document.objectId,
            localEvents: [.setLoadingState(blockId: blockId)]
        ).send()
        
        let operation = MediaFileUploadingOperation(
            uploadingSource: uploadingSource,
            worker: BlockMediaUploadingWorker(
                objectId: document.objectId,
                blockId: blockId,
                contentType: type
            )
        )
        fileUploadingDemon.addOperation(operation)

        AnytypeAnalytics.instance().logUploadMedia(type: type.asFileBlockContentType)
    }
    
    func uploadFileAt(localPath: String, blockId: BlockId) {
        AnytypeAnalytics.instance().logUploadMedia(type: .file)

        EventsBunch(
            contextId: document.objectId,
            localEvents: [.setLoadingState(blockId: blockId)]
        ).send()
        
        upload(blockId: blockId, filePath: localPath)
    }
    
    func createPage(targetId: BlockId, type: ObjectTypeUrl) -> BlockId? {
        guard let info = document.infoContainer.get(id: targetId) else { return nil }
        var position: BlockPosition
        if case .text(let blockText) = info.content, blockText.text.isEmpty {
            position = .replace
        } else {
            position = .bottom
        }
        
        return service.createPage(targetId: targetId, type: type, position: position)
    }


    func createTable(
        blockId: BlockId,
        rowsCount: Int,
        columnsCount: Int,
        blockText: NSAttributedString?
    ) {
        let blockText = FeatureFlags.fixInsetMediaContent ? blockText : nil
        
        guard let isTextAndEmpty = blockText?.string.isEmpty
                ?? document.infoContainer.get(id: blockId)?.isTextAndEmpty else { return }
        
        let position: BlockPosition = isTextAndEmpty ? .replace : .bottom

        blockTableService.createTable(
            contextId: document.objectId,
            targetId: blockId,
            position: position,
            rowsCount: rowsCount,
            columnsCount: columnsCount
        )
    }


    func addBlock(_ type: BlockContentType, blockId: BlockId, blockText: NSAttributedString?, position: BlockPosition?) {
        guard type != .smartblock(.page) else {
            anytypeAssertionFailure("Use createPage func instead", domain: .blockActionsService)
            return
        }
            
        guard let newBlock = BlockBuilder.createNewBlock(type: type) else { return }

        let blockText = FeatureFlags.fixInsetMediaContent ? blockText : nil
        
        guard let isTextAndEmpty = blockText?.string.isEmpty
            ?? document.infoContainer.get(id: blockId)?.isTextAndEmpty else { return }
        
        let position: BlockPosition = isTextAndEmpty ? .replace : (position ?? .bottom)

        service.add(info: newBlock, targetBlockId: blockId, position: position)
    }

    func selectBlock(info: BlockInformation) {
        blockSelectionHandler?.didSelectEditingState(info: info)
    }

    func createAndFetchBookmark(
        targetID: BlockId,
        position: BlockPosition,
        url: AnytypeURL
    ) {
        service.createAndFetchBookmark(
            contextID: document.objectId,
            targetID: targetID,
            position: position,
            url: url
        )
    }

    func setAppearance(blockId: BlockId, appearance: BlockLink.Appearance) {
        listService.setLinkAppearance(blockIds: [blockId], appearance: appearance)
    }
}
