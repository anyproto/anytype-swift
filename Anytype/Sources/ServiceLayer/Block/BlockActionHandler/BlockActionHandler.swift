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
    
    private let fileUploadingDemon = MediaFileUploadingDemon.shared
    
    init(
        document: BaseDocumentProtocol,
        markupChanger: BlockMarkupChangerProtocol,
        service: BlockActionServiceProtocol,
        listService: BlockListServiceProtocol,
        keyboardHandler: KeyboardActionHandlerProtocol
    ) {
        self.document = document
        self.markupChanger = markupChanger
        self.service = service
        self.listService = listService
        self.keyboardHandler = keyboardHandler
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
    
    func setTextColor(_ color: BlockColor, blockId: BlockId) {
        listService.setBlockColor(blockIds: [blockId], color: color.middleware)
    }
    
    func setBackgroundColor(_ color: BlockBackgroundColor, blockId: BlockId) {
        service.setBackgroundColor(blockId: blockId, color: color)
    }
    
    func duplicate(blockId: BlockId) {
        service.duplicate(blockId: blockId)
    }
    
    func setFields(_ fields: FieldsConvertibleProtocol, blockId: BlockId) {
        guard let info = document.infoContainer.get(id: blockId) else { return }

        let newFields = info.fields.merging(fields.asMiddleware()) { (_, new) in new }

        service.setFields(blockFields: newFields, blockId: blockId)
    }
    
    func fetch(url: URL, blockId: BlockId) {
        service.bookmarkFetch(blockId: blockId, url: url.absoluteString)
    }
    
    func checkbox(selected: Bool, blockId: BlockId) {
        service.checked(blockId: blockId, newValue: selected)
    }
    
    func toggle(blockId: BlockId) {
        EventsBunch(contextId: document.objectId.value, localEvents: [.setToggled(blockId: blockId)])
            .send()
    }
    
    func setAlignment(_ alignment: LayoutAlignment, blockId: BlockId) {
        listService.setAlign(blockIds: [blockId], alignment: alignment)
    }
    
    func delete(blockId: BlockId) {
        service.delete(blockId: blockId)
    }
    
    func moveToPage(blockId: BlockId, pageId: BlockId) {
        listService.moveToPage(blockId: blockId, pageId: pageId)
    }
    
    func createEmptyBlock(parentId: BlockId) {
        service.addChild(info: BlockInformation.emptyText, parentId: parentId)
    }
    
    func addLink(targetId: BlockId, blockId: BlockId) {
        service.add(
            info: .emptyLink(targetId: targetId),
            targetBlockId: blockId,
            position: .bottom
        )
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
        info: BlockInformation
    ) {
        keyboardHandler.handle(info: info, action: action)
    }
    
    func changeTextForced(_ text: NSAttributedString, blockId: BlockId) {
        guard let info = document.infoContainer.get(id: blockId) else { return }

        guard case .text = info.content else { return }

        let middlewareString = AttributedTextConverter.asMiddleware(attributedText: text)

        EventsBunch(
            contextId: document.objectId.value,
            localEvents: [.setText(blockId: info.id.value, text: middlewareString)]
        ).send()

        service.setTextForced(contextId: document.objectId.value, blockId: info.id.value, middlewareString: middlewareString)
    }
    
    func changeText(_ text: NSAttributedString, info: BlockInformation) {
        guard case .text = info.content else { return }

        let middlewareString = AttributedTextConverter.asMiddleware(attributedText: text)

        EventsBunch(
            contextId: document.objectId.value,
            dataSourceUpdateEvents: [.setText(blockId: info.id.value, text: middlewareString)]
        ).send()

        service.setText(contextId: document.objectId.value, blockId: info.id.value, middlewareString: middlewareString)
    }
    
    // MARK: - Public methods
    func uploadMediaFile(itemProvider: NSItemProvider, type: MediaPickerContentType, blockId: BlockId) {
        EventsBunch(
            contextId: document.objectId.value,
            localEvents: [.setLoadingState(blockId: blockId)]
        ).send()
        
        let operation = MediaFileUploadingOperation(
            itemProvider: itemProvider,
            worker: BlockMediaUploadingWorker(
                objectId: document.objectId.value,
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
            contextId: document.objectId.value,
            localEvents: [.setLoadingState(blockId: blockId)]
        ).send()
        
        upload(blockId: blockId, filePath: localPath)
    }
    
    func createPage(targetId: BlockId, type: ObjectTemplateType, route: AnalyticsEventsRouteKind) -> BlockId? {
        guard let info = document.infoContainer.get(id: targetId) else { return nil }
        var position: BlockPosition
        if case .text(let blockText) = info.content, blockText.text.isEmpty {
            position = .replace
        } else {
            position = .bottom
        }
        
        return service.createPage(targetId: targetId, type: type, position: position, route: route)
    }

    func addBlock(_ type: BlockContentType, blockId: BlockId) {
        guard type != .smartblock(.page) else {
            anytypeAssertionFailure("Use createPage func instead", domain: .blockActionsService)
//            _ = service.createPage(targetId: blockId, type: .bundled(.page), position: .bottom)
            return
        }
            
        guard let newBlock = BlockBuilder.createNewBlock(type: type) else { return }
        guard let info = document.infoContainer.get(id: blockId) else { return }
        
        let position: BlockPosition = info.isTextAndEmpty ? .replace : .bottom
        
        service.add(info: newBlock, targetBlockId: info.id.value, position: position)
    }

    func selectBlock(info: BlockInformation) {
        blockSelectionHandler?.didSelectEditingState(info: info)
    }

    func createAndFetchBookmark(
        targetID: BlockId,
        position: BlockPosition,
        url: String
    ) {
        service.createAndFetchBookmark(
            contextID: document.objectId.value,
            targetID: targetID,
            position: position,
            url: url
        )
    }
}
