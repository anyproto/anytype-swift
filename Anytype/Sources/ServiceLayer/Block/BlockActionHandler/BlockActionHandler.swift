import UIKit
import Services
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
    private let fileService: FileActionsServiceProtocol
    private let objectService: ObjectActionsServiceProtocol
    
    init(
        document: BaseDocumentProtocol,
        markupChanger: BlockMarkupChangerProtocol,
        service: BlockActionServiceProtocol,
        listService: BlockListServiceProtocol,
        keyboardHandler: KeyboardActionHandlerProtocol,
        blockTableService: BlockTableServiceProtocol,
        fileService: FileActionsServiceProtocol,
        objectService: ObjectActionsServiceProtocol
    ) {
        self.document = document
        self.markupChanger = markupChanger
        self.service = service
        self.listService = listService
        self.keyboardHandler = keyboardHandler
        self.blockTableService = blockTableService
        self.fileService = fileService
        self.objectService = objectService
    }

    // MARK: - Service proxy

    func turnIntoPage(blockId: BlockId) async throws -> BlockId? {
        try await service.turnIntoPage(blockId: blockId, spaceId: document.spaceId)
    }
    
    func turnInto(_ style: BlockText.Style, blockId: BlockId) {
        defer { AnytypeAnalytics.instance().logChangeBlockStyle(style) }
        
        switch style {
        case .toggle:
            if let blockInformation = document.infoContainer.get(id: blockId),
               blockInformation.childrenIds.count > 0, !blockInformation.isToggled {
                blockInformation.toggle()
            }
            service.turnInto(style, blockId: blockId)
        default:
            service.turnInto(style, blockId: blockId)
        }
    }
    
    func upload(blockId: BlockId, filePath: String) async throws {
        try await service.upload(blockId: blockId, filePath: filePath)
    }
    
    @MainActor
    func setObjectType(type: ObjectType) async throws {
        if #available(iOS 17.0, *) {
            HomeCreateObjectTip.objectTpeChanged = true
        }
        try await service.setObjectType(type: type)
    }

    func setObjectSetType() async throws {
        try await service.setObjectSetType()
    }
    
    func setObjectCollectionType() async throws {
        try await service.setObjectCollectionType()
    }
    
    func applyTemplate(objectId: String, templateId: String) async throws {
        try await objectService.applyTemplate(objectId: objectId, templateId: templateId)
    }
    
    func setTextColor(_ color: BlockColor, blockIds: [BlockId]) {
        Task {
            try await listService.setBlockColor(objectId: document.objectId, blockIds: blockIds, color: color.middleware)
        }
    }
    
    func setBackgroundColor(_ color: BlockBackgroundColor, blockIds: [BlockId]) {
        service.setBackgroundColor(blockIds: blockIds, color: color)
    }
    
    func duplicate(blockId: BlockId) {
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.blockListDuplicate)
        service.duplicate(blockId: blockId)
    }
    
    func fetch(url: AnytypeURL, blockId: BlockId) {
        service.bookmarkFetch(blockId: blockId, url: url)
    }
    
    func checkbox(selected: Bool, blockId: BlockId) {
        service.checked(blockId: blockId, newValue: selected)
    }
    
    func toggle(blockId: BlockId) {
        Task {
            await EventsBunch(contextId: document.objectId, localEvents: [.setToggled(blockId: blockId)])
                .send()
        }
    }
    
    func setAlignment(_ alignment: LayoutAlignment, blockIds: [BlockId]) {
        Task {
            try await listService.setAlign(objectId: document.objectId, blockIds: blockIds, alignment: alignment)
        }
    }
    
    func delete(blockIds: [BlockId]) {
        service.delete(blockIds: blockIds)
    }
    
    func moveToPage(blockId: BlockId, pageId: BlockId) {
        AnytypeAnalytics.instance().logMoveBlock()
        Task {
            try await listService.moveToPage(objectId: document.objectId, blockId: blockId, pageId: pageId)
        }
    }
    
    func createEmptyBlock(parentId: BlockId) {
        let emptyBlock = BlockInformation.emptyText
        AnytypeAnalytics.instance().logCreateBlock(type: emptyBlock.content.type)
        service.addChild(info: emptyBlock, parentId: parentId)
    }
    
    func addLink(targetDetails: ObjectDetails, blockId: BlockId) {
        let isBookmarkType = targetDetails.layoutValue == .bookmark
        AnytypeAnalytics.instance().logCreateLink()
        service.add(
            info: isBookmarkType ? .bookmark(targetId: targetDetails.id) : .emptyLink(targetId: targetDetails.id),
            targetBlockId: blockId,
            position: .replace
        )
    }
    
    func changeMarkup(blockIds: [BlockId], markType: MarkupType) {
        Task {
            AnytypeAnalytics.instance().logChangeBlockStyle(markType)
            try await listService.changeMarkup(objectId: document.objectId, blockIds: blockIds, markType: markType)
        }
    }
    
    // MARK: - Markup changer proxy
    func toggleWholeBlockMarkup(_ markup: MarkupType, blockId: BlockId) {
        guard let newText = markupChanger.toggleMarkup(markup, blockId: blockId) else { return }
        
        changeTextForced(newText, blockId: blockId)
    }
    
    func changeTextStyle(_ attribute: MarkupType, range: NSRange, blockId: BlockId) {
        guard let newText = markupChanger.toggleMarkup(attribute, blockId: blockId, range: range) else { return }

        AnytypeAnalytics.instance().logChangeTextStyle(attribute)

        changeTextForced(newText, blockId: blockId)
    }
    
    func setTextStyle(_ attribute: MarkupType, range: NSRange, blockId: BlockId, currentText: NSAttributedString?) {
        guard let newText = markupChanger.setMarkup(attribute, blockId: blockId, range: range, currentText: currentText)
            else { return }

        AnytypeAnalytics.instance().logChangeTextStyle(attribute)

        changeTextForced(newText, blockId: blockId)
    }
    
    func setLink(url: URL?, range: NSRange, blockId: BlockId) {
        let newText: NSAttributedString?
        AnytypeAnalytics.instance().logChangeTextStyle(MarkupType.link(url))
        if let url = url {
            newText = markupChanger.setMarkup(.link(url), blockId: blockId, range: range)
        } else {
            newText = markupChanger.removeMarkup(.link(nil), blockId: blockId, range: range)
        }
        
        guard let newText = newText else { return }
        changeTextForced(newText, blockId: blockId)
    }
    
    func setLinkToObject(linkBlockId: BlockId?, range: NSRange, blockId: BlockId) {
        let newText: NSAttributedString?
        AnytypeAnalytics.instance().logChangeTextStyle(MarkupType.linkToObject(linkBlockId))
        if let linkBlockId = linkBlockId {
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
        let safeSendableText = SafeSendable(value: text)
        
        Task {
            guard let info = document.infoContainer.get(id: blockId) else { return }
            
            guard case .text = info.content else { return }
            
            let middlewareString = AttributedTextConverter.asMiddleware(attributedText: safeSendableText.value)
            
            await EventsBunch(
                contextId: document.objectId,
                localEvents: [.setText(blockId: info.id, text: middlewareString)]
            ).send()
            
            try await service.setTextForced(contextId: document.objectId, blockId: info.id, middlewareString: middlewareString)
        }
    }
    
    func changeText(_ text: NSAttributedString, info: BlockInformation) {
        let safeSendableText = SafeSendable(value: text)

        Task {
            guard case .text = info.content else { return }
            
            let middlewareString = AttributedTextConverter.asMiddleware(attributedText: safeSendableText.value)
            
            await EventsBunch(
                contextId: document.objectId,
                dataSourceUpdateEvents: [.setText(blockId: info.id, text: middlewareString)]
            ).send()
            
            try await service.setText(contextId: document.objectId, blockId: info.id, middlewareString: middlewareString)
        }
    }
    
    // MARK: - Public methods
    func uploadMediaFile(uploadingSource: FileUploadingSource, type: MediaPickerContentType, blockId: BlockId) {
        
        Task {
            
            await EventsBunch(
                contextId: document.objectId,
                localEvents: [.setLoadingState(blockId: blockId)]
            ).send()
            
            try await fileService.uploadDataAt(source: uploadingSource, contextID: document.objectId, blockID: blockId)
        }

        AnytypeAnalytics.instance().logUploadMedia(type: type.asFileBlockContentType)
    }
    
    func uploadFileAt(localPath: String, blockId: BlockId) {
        AnytypeAnalytics.instance().logUploadMedia(type: .file)
        
        Task {
            await EventsBunch(
                contextId: document.objectId,
                localEvents: [.setLoadingState(blockId: blockId)]
            ).send()
            
            try await upload(blockId: blockId, filePath: localPath)
        }
    }
    
    func createPage(targetId: BlockId, spaceId: String, typeUniqueKey: ObjectTypeUniqueKey, templateId: String) async throws -> BlockId? {
        guard let info = document.infoContainer.get(id: targetId) else { return nil }
        var position: BlockPosition
        if case .text(let blockText) = info.content, blockText.text.isEmpty {
            position = .replace
        } else {
            position = .bottom
        }
        return try await service.createPage(targetId: targetId, spaceId: spaceId, typeUniqueKey: typeUniqueKey, position: position, templateId: templateId)
    }

    func createTable(
        blockId: BlockId,
        rowsCount: Int,
        columnsCount: Int,
        blockText: SafeSendable<NSAttributedString?>
    ) async throws -> BlockId {
        guard let isTextAndEmpty = blockText.value?.string.isEmpty
                ?? document.infoContainer.get(id: blockId)?.isTextAndEmpty else { return "" }
        
        let position: BlockPosition = isTextAndEmpty ? .replace : .bottom

        AnytypeAnalytics.instance().logCreateBlock(type: TableBlockType.simpleTableBlock.rawValue)
        
        return try await blockTableService.createTable(
            contextId: document.objectId,
            targetId: blockId,
            position: position,
            rowsCount: rowsCount,
            columnsCount: columnsCount
        )
    }


    func addBlock(_ type: BlockContentType, blockId: BlockId, blockText: NSAttributedString?, position: BlockPosition?) {
        guard type != .smartblock(.page) else {
            anytypeAssertionFailure("Use createPage func instead")
            return
        }
            
        guard let newBlock = BlockBuilder.createNewBlock(type: type) else { return }

        guard let isTextAndEmpty = blockText?.string.isEmpty
            ?? document.infoContainer.get(id: blockId)?.isTextAndEmpty else { return }
        
        let position: BlockPosition = isTextAndEmpty ? .replace : (position ?? .bottom)
        
        AnytypeAnalytics.instance().logCreateBlock(type: newBlock.content.type)
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
        Task {
            try await listService.setLinkAppearance(objectId: document.objectId, blockIds: [blockId], appearance: appearance)
        }
    }
}
