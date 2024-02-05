import UIKit
import Services
import Combine
import AnytypeCore
import ProtobufMessages

final class BlockActionHandler: BlockActionHandlerProtocol {
    private let document: BaseDocumentProtocol
    
    private let service: BlockActionServiceProtocol
    private let blockService: BlockServiceProtocol
    private let markupChanger: BlockMarkupChangerProtocol
    private let blockTableService: BlockTableServiceProtocol
    private let fileService: FileActionsServiceProtocol
    private let objectService: ObjectActionsServiceProtocol
    
    init(
        document: BaseDocumentProtocol,
        markupChanger: BlockMarkupChangerProtocol,
        service: BlockActionServiceProtocol,
        blockService: BlockServiceProtocol,
        blockTableService: BlockTableServiceProtocol,
        fileService: FileActionsServiceProtocol,
        objectService: ObjectActionsServiceProtocol
    ) {
        self.document = document
        self.markupChanger = markupChanger
        self.service = service
        self.blockService = blockService
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
            try await blockService.setBlockColor(objectId: document.objectId, blockIds: blockIds, color: color.middleware)
        }
    }
    
    func setBackgroundColor(_ color: BlockBackgroundColor, blockIds: [BlockId]) {
        AnytypeAnalytics.instance().logChangeBlockBackground(color: color.middleware)
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
        AnytypeAnalytics.instance().logSetAlignment(alignment, isBlock: blockIds.isNotEmpty)
        Task {
            try await blockService.setAlign(objectId: document.objectId, blockIds: blockIds, alignment: alignment)
        }
    }
    
    func delete(blockIds: [BlockId]) {
        service.delete(blockIds: blockIds)
    }
    
    func moveToPage(blockId: BlockId, pageId: BlockId) {
        AnytypeAnalytics.instance().logMoveBlock()
        Task {
            try await blockService.moveToPage(objectId: document.objectId, blockId: blockId, pageId: pageId)
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
            try await blockService.changeMarkup(objectId: document.objectId, blockIds: blockIds, markType: markType)
        }
    }
    
    // MARK: - Markup changer proxy
    func toggleWholeBlockMarkup(
        _ attributedString: NSAttributedString?,
        markup: MarkupType,
        info: BlockInformation
    ) -> NSAttributedString? {
        guard let textContent = info.textContent, let attributedString else { return nil }
        let changedAttributedString = markupChanger.toggleMarkup(
            attributedString,
            markup: markup,
            contentType: .text(textContent.contentType)
        )
        
        changeText(changedAttributedString, blockId: info.id)
        
        return changedAttributedString
    }

    func setTextStyle(
        _ attribute: MarkupType,
        range: NSRange,
        blockId: BlockId,
        currentText: NSAttributedString?,
        contentType: BlockContentType
    ) {
        guard let currentText else { return }
        let newText = markupChanger.setMarkup(
            attribute,
            range: range,
            attributedString: currentText,
            contentType: contentType
        )

        AnytypeAnalytics.instance().logChangeTextStyle(attribute)

        changeText(newText, blockId: blockId)
    }
    
    func changeText(_ text: NSAttributedString, blockId: BlockId) {
        let safeSendableText = SafeSendable(value: text)

        Task {
            let middlewareString = AttributedTextConverter.asMiddleware(attributedText: safeSendableText.value)
            
            await EventsBunch(
                contextId: document.objectId,
                localEvents: [.setText(blockId: blockId, text: middlewareString)]
            ).send()


            try await service.setText(contextId: document.objectId, blockId: blockId, middlewareString: middlewareString)
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
            try await blockService.setLinkAppearance(objectId: document.objectId, blockIds: [blockId], appearance: appearance)
        }
    }
}
