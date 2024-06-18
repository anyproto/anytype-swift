import UIKit
import Services
import Combine
import AnytypeCore
import ProtobufMessages

final class BlockActionHandler: BlockActionHandlerProtocol {
    private let document: BaseDocumentProtocol
    
    private let service: BlockActionServiceProtocol
    private let markupChanger: BlockMarkupChangerProtocol
    
    
    @Injected(\.blockService)
    private var blockService: BlockServiceProtocol
    @Injected(\.blockTableService)
    private var blockTableService: BlockTableServiceProtocol
    @Injected(\.fileActionsService)
    private var fileService: FileActionsServiceProtocol
    @Injected(\.objectActionsService)
    private var objectService: ObjectActionsServiceProtocol
    @Injected(\.pasteboardBlockService)
    private var pasteboardBlockService: PasteboardBlockServiceProtocol
    @Injected(\.bookmarkService)
    private var bookmarkService: BookmarkServiceProtocol
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: ObjectTypeProviderProtocol
    
    init(
        document: BaseDocumentProtocol,
        markupChanger: BlockMarkupChangerProtocol,
        service: BlockActionServiceProtocol
    ) {
        self.document = document
        self.markupChanger = markupChanger
        self.service = service
    }

    // MARK: - Service proxy

    func turnIntoPage(blockId: String) async throws -> String? {
        try await service.turnIntoPage(blockId: blockId, spaceId: document.spaceId)
    }
    
    func turnInto(_ style: BlockText.Style, blockId: String) async throws {
        switch style {
        case .toggle:
            if let blockInformation = document.infoContainer.get(id: blockId),
               blockInformation.childrenIds.count > 0, !blockInformation.isToggled {
                blockInformation.toggle()
            }
            try await service.turnInto(style, blockId: blockId)
        default:
            try await service.turnInto(style, blockId: blockId)
        }
        AnytypeAnalytics.instance().logChangeBlockStyle(style)
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
    
    func duplicate(blockId: String, spaceId: String) {
        AnytypeAnalytics.instance().logDuplicateBlock(spaceId: spaceId)
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
    
    func createEmptyBlock(parentId: String, spaceId: String) {
        Task {
            let emptyBlock = BlockInformation.emptyText
            AnytypeAnalytics.instance().logCreateBlock(type: emptyBlock.content.type, spaceId: spaceId)
            try await service.addChild(info: emptyBlock, parentId: parentId)
        }
    }
    
    func addLink(targetDetails: ObjectDetails, blockId: String) {
        Task {
            let isBookmarkType = targetDetails.layoutValue == .bookmark
            AnytypeAnalytics.instance().logCreateLink(spaceId: targetDetails.spaceId)
            try await service.add(
                info: isBookmarkType ? .bookmark(targetId: targetDetails.id) : .emptyLink(targetId: targetDetails.id),
                targetBlockId: blockId,
                position: .replace
            )
        }
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
    ) async throws -> NSAttributedString? {
        guard let textContent = info.textContent, let attributedString else { return nil }
        let changedAttributedString = markupChanger.toggleMarkup(
            attributedString,
            markup: markup,
            contentType: .text(textContent.contentType)
        )
        
        try await changeText(changedAttributedString, blockId: info.id)
        
        return changedAttributedString
    }

    func setTextStyle(
        _ attribute: MarkupType,
        range: NSRange,
        blockId: String,
        currentText: NSAttributedString?,
        contentType: BlockContentType
    ) async throws {
        guard let currentText else { return }
        let newText = markupChanger.setMarkup(
            attribute,
            range: range,
            attributedString: currentText,
            contentType: contentType
        )

        AnytypeAnalytics.instance().logChangeTextStyle(attribute)

        try await changeText(newText, blockId: blockId)
    }
    
    func changeText(_ text: NSAttributedString, blockId: String) async throws {
        let safeSendableText = SafeSendable(value: text)

        let middlewareString = AttributedTextConverter.asMiddleware(attributedText: safeSendableText.value)
            
        await EventsBunch(
            contextId: document.objectId,
            localEvents: [.setText(blockId: blockId, text: middlewareString)]
        ).send()


        try await service.setText(contextId: document.objectId, blockId: blockId, middlewareString: middlewareString)
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

        AnytypeAnalytics.instance().logUploadMedia(type: type.asFileBlockContentType, spaceId: document.spaceId)
    }
    
    func uploadFileAt(localPath: String, blockId: String) {
        AnytypeAnalytics.instance().logUploadMedia(type: .file, spaceId: document.spaceId)
        
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
        blockText: SafeSendable<NSAttributedString?>,
        spaceId: String
    ) async throws -> String {
        guard let isTextAndEmpty = blockText.value?.string.isEmpty
                ?? document.infoContainer.get(id: blockId)?.isTextAndEmpty else { return "" }
        
        let position: BlockPosition = isTextAndEmpty ? .replace : .bottom

        AnytypeAnalytics.instance().logCreateBlock(type: TableBlockType.simpleTableBlock.rawValue, spaceId: spaceId)
        
        return try await blockTableService.createTable(
            contextId: document.objectId,
            targetId: blockId,
            position: position,
            rowsCount: rowsCount,
            columnsCount: columnsCount
        )
    }


    func addBlock(_ type: BlockContentType, blockId: String, blockText: NSAttributedString?, position: BlockPosition?, spaceId: String) {
        guard type != .smartblock(.page) else {
            anytypeAssertionFailure("Use createPage func instead")
            return
        }
            
        guard let newBlock = BlockBuilder.createNewBlock(type: type) else { return }

        guard let isTextAndEmpty = blockText?.string.isEmpty
            ?? document.infoContainer.get(id: blockId)?.isTextAndEmpty else { return }
        
        let position: BlockPosition = isTextAndEmpty ? .replace : (position ?? .bottom)
        
        AnytypeAnalytics.instance().logCreateBlock(type: newBlock.content.type, spaceId: spaceId)
        Task {
            try await service.add(info: newBlock, targetBlockId: blockId, position: position)
        }
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
                spaceId: document.spaceId,
                focusedBlockId: blockId,
                range: .zero,
                handleLongOperation: { },
                completion: { _ in }
            )
        }
    }
}
