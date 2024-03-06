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
    private let pasteboardBlockService: PasteboardBlockServiceProtocol
    private let bookmarkService: BookmarkServiceProtocol
    private let objectTypeProvider: ObjectTypeProviderProtocol
    
    init(
        document: BaseDocumentProtocol,
        markupChanger: BlockMarkupChangerProtocol,
        service: BlockActionServiceProtocol,
        blockService: BlockServiceProtocol,
        blockTableService: BlockTableServiceProtocol,
        fileService: FileActionsServiceProtocol,
        objectService: ObjectActionsServiceProtocol,
        pasteboardBlockService: PasteboardBlockServiceProtocol,
        bookmarkService: BookmarkServiceProtocol,
        objectTypeProvider: ObjectTypeProviderProtocol
    ) {
        self.document = document
        self.markupChanger = markupChanger
        self.service = service
        self.blockService = blockService
        self.blockTableService = blockTableService
        self.fileService = fileService
        self.objectService = objectService
        self.pasteboardBlockService = pasteboardBlockService
        self.bookmarkService = bookmarkService
        self.objectTypeProvider = objectTypeProvider
    }

    // MARK: - Service proxy

    func turnIntoPage(blockId: String) async throws -> String? {
        try await service.turnIntoPage(blockId: blockId, spaceId: document.spaceId)
    }
    
    func turnInto(_ style: BlockText.Style, blockId: String) {
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
    
    func upload(blockId: String, filePath: String) async throws {
        try await service.upload(blockId: blockId, filePath: filePath)
    }
    
    @MainActor
    func setObjectType(type: ObjectType) async throws {
        if #available(iOS 17.0, *) {
            HomeCreateObjectTip.objectTypeChanged = true
        }
        try await service.setObjectType(type: type)
    }
    
    @discardableResult
    func turnIntoBookmark(url: AnytypeURL) async throws -> ObjectType {
        let type = try objectTypeProvider.objectType(uniqueKey: .bookmark, spaceId: document.spaceId)
        try await setObjectType(type: type)
        try await bookmarkService.fetchBookmarkContent(bookmarkId: document.objectId, url: url)
        return type
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
    
    func setTextColor(_ color: BlockColor, blockIds: [String]) {
        Task {
            try await blockService.setBlockColor(objectId: document.objectId, blockIds: blockIds, color: color.middleware)
        }
    }
    
    func setBackgroundColor(_ color: BlockBackgroundColor, blockIds: [String]) {
        AnytypeAnalytics.instance().logChangeBlockBackground(color: color.middleware)
        service.setBackgroundColor(blockIds: blockIds, color: color)
    }
    
    func duplicate(blockId: String) {
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.blockListDuplicate)
        service.duplicate(blockId: blockId)
    }
    
    func fetch(url: AnytypeURL, blockId: String) {
        service.bookmarkFetch(blockId: blockId, url: url)
    }
    
    func checkbox(selected: Bool, blockId: String) {
        service.checked(blockId: blockId, newValue: selected)
    }
    
    func toggle(blockId: String) {
        Task {
            await EventsBunch(contextId: document.objectId, localEvents: [.setToggled(blockId: blockId)])
                .send()
        }
    }
    
    func setAlignment(_ alignment: LayoutAlignment, blockIds: [String]) {
        AnytypeAnalytics.instance().logSetAlignment(alignment, isBlock: blockIds.isNotEmpty)
        Task {
            try await blockService.setAlign(objectId: document.objectId, blockIds: blockIds, alignment: alignment)
        }
    }
    
    func delete(blockIds: [String]) {
        service.delete(blockIds: blockIds)
    }
    
    func moveToPage(blockId: String, pageId: String) {
        AnytypeAnalytics.instance().logMoveBlock()
        Task {
            try await blockService.moveToPage(objectId: document.objectId, blockId: blockId, pageId: pageId)
        }
    }
    
    func createEmptyBlock(parentId: String) {
        let emptyBlock = BlockInformation.emptyText
        AnytypeAnalytics.instance().logCreateBlock(type: emptyBlock.content.type)
        service.addChild(info: emptyBlock, parentId: parentId)
    }
    
    func addLink(targetDetails: ObjectDetails, blockId: String) {
        let isBookmarkType = targetDetails.layoutValue == .bookmark
        AnytypeAnalytics.instance().logCreateLink()
        service.add(
            info: isBookmarkType ? .bookmark(targetId: targetDetails.id) : .emptyLink(targetId: targetDetails.id),
            targetBlockId: blockId,
            position: .replace
        )
    }
    
    func changeMarkup(blockIds: [String], markType: MarkupType) {
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
        blockId: String,
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
    
    func changeText(_ text: NSAttributedString, blockId: String) {
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
    func uploadMediaFile(uploadingSource: FileUploadingSource, type: MediaPickerContentType, blockId: String) {
        
        Task {
            
            await EventsBunch(
                contextId: document.objectId,
                localEvents: [.setLoadingState(blockId: blockId)]
            ).send()
            
            try await fileService.uploadDataAt(source: uploadingSource, contextID: document.objectId, blockID: blockId)
        }

        AnytypeAnalytics.instance().logUploadMedia(type: type.asFileBlockContentType)
    }
    
    func uploadFileAt(localPath: String, blockId: String) {
        AnytypeAnalytics.instance().logUploadMedia(type: .file)
        
        Task {
            await EventsBunch(
                contextId: document.objectId,
                localEvents: [.setLoadingState(blockId: blockId)]
            ).send()
            
            try await upload(blockId: blockId, filePath: localPath)
        }
    }
    
    func createPage(targetId: String, spaceId: String, typeUniqueKey: ObjectTypeUniqueKey, templateId: String) async throws -> String? {
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
        blockId: String,
        rowsCount: Int,
        columnsCount: Int,
        blockText: SafeSendable<NSAttributedString?>
    ) async throws -> String {
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


    func addBlock(_ type: BlockContentType, blockId: String, blockText: NSAttributedString?, position: BlockPosition?) {
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
        targetID: String,
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

    func setAppearance(blockId: String, appearance: BlockLink.Appearance) {
        Task {
            try await blockService.setLinkAppearance(objectId: document.objectId, blockIds: [blockId], appearance: appearance)
        }
    }
    
    func pasteContent() {
        Task {
            let blockId = try await blockService.addFirstBlock(contextId: document.objectId, info: .emptyText)
            pasteboardBlockService.pasteInsideBlock(
                objectId: document.objectId,
                focusedBlockId: blockId,
                range: .zero,
                handleLongOperation: { },
                completion: { _ in }
            )
        }
    }
}
