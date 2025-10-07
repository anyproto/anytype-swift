import Foundation
import Services
import AnytypeCore
import UIKit

@MainActor
final class SlashMenuActionHandler {
    private let actionHandler: any BlockActionHandlerProtocol
    private let router: any EditorRouterProtocol
    private let document: any BaseDocumentProtocol
    private let cursorManager: EditorCursorManager
    private let mediaBlockActionsProvider: any MediaBlockActionsProviderProtocol
    
    private weak var textView: UITextView?
    
    @Injected(\.pasteboardBlockDocumentService)
    private var pasteboardService: any PasteboardBlockDocumentServiceProtocol
    @Injected(\.objectDateByTimestampService)
    private var objectDateByTimestampService: any ObjectDateByTimestampServiceProtocol
    
    init(
        document: some BaseDocumentProtocol,
        actionHandler: some BlockActionHandlerProtocol,
        router: some EditorRouterProtocol,
        cursorManager: EditorCursorManager,
        mediaBlockActionsProvider: some MediaBlockActionsProviderProtocol
    ) {
        self.document = document
        self.actionHandler = actionHandler
        self.router = router
        self.cursorManager = cursorManager
        self.mediaBlockActionsProvider = mediaBlockActionsProvider
    }
    
    func handle(
        _ action: SlashAction,
        textView: UITextView?,
        blockInformation: BlockInformation,
        modifiedStringHandler: (SafeNSAttributedString?) -> Void
    ) async throws {
        switch action {
        case let .actions(action):
            try await handleActions(action, textView: textView, blockId: blockInformation.id)
        case let .alignment(alignmnet):
            handleAlignment(alignmnet, blockIds: [blockInformation.id])
        case let .style(style):
            try await handleStyle(style, attributedString: textView?.attributedText.sendable(), blockInformation: blockInformation, modifiedStringHandler: modifiedStringHandler)
        case let .media(media):
            try await handleMediaAction(media, textView: textView, blockInformation: blockInformation)
        case let .objects(action):
            switch action {
            case .date:
                textView?.shouldResignFirstResponder()
                router.showDatePicker { [weak self] newDate in
                    self?.handleDate(newDate, blockId: blockInformation.id)
                }
            case .objectType(let typeDetails):
                let objectType = ObjectType(details: typeDetails)
                AnytypeAnalytics.instance().logCreateLink(spaceId: objectType.spaceId, objectType: objectType.analyticsType, route: .slashMenu)
                try await actionHandler
                    .createPage(
                        targetId: blockInformation.id,
                        spaceId: objectType.spaceId,
                        typeUniqueKey: objectType.uniqueKey,
                        templateId: objectType.defaultTemplateId
                    )
                    .flatMap { objectId in
                        AnytypeAnalytics.instance().logCreateObject(objectType: objectType.analyticsType, spaceId: objectType.spaceId, route: .slashMenu)
                        router.showEditorScreen(data: .editor(editorScreenData(objectId: objectId, objectType: objectType)))
                    }
            }
        case let .relations(action):
            switch action {
            case .newRealtion:
                router.showAddPropertyInfoView(document: document) { [weak self, spaceId = document.spaceId] relation, isNew in
                    Task {
                        try await self?.actionHandler.addBlock(.relation(key: relation.key), blockId: blockInformation.id, blockText: textView?.attributedText.sendable())
                    }
                    AnytypeAnalytics.instance().logAddExistingOrCreateRelation(
                        format: relation.format,
                        isNew: isNew,
                        type: .block,
                        key: relation.analyticsKey,
                        spaceId: spaceId,
                        route: .slashMenu
                    )
                }
            case .relation(let relation):
                try await actionHandler.addBlock(.relation(key: relation.key), blockId: blockInformation.id, blockText: textView?.attributedText.sendable())
            }
        case let .other(other):
            switch other {
            case .table(let rowsCount, let columnsCount):
                guard let blockId = try? await actionHandler.createTable(
                    blockId: blockInformation.id,
                    rowsCount: rowsCount,
                    columnsCount: columnsCount,
                    blockText: textView?.attributedText.sendable()
                ) else { return }
                
                cursorManager.blockFocus = BlockFocus(id: blockId, position: .beginning)
            default:
                try await actionHandler.addBlock(other.blockViewsType, blockId: blockInformation.id, blockText: textView?.attributedText.sendable())
            }
        case let .color(color):
            actionHandler.setTextColor(color, blockIds: [blockInformation.id], route: .slashMenu)
        case let .background(color):
            actionHandler.setBackgroundColor(color, blockIds: [blockInformation.id], route: .slashMenu)
        case let .single(single):
            switch single {
            case .camera:
                let blockId = try await actionHandler.addBlock(single.blockViewsType, blockId: blockInformation.id, blockText: textView?.attributedText.sendable())
                mediaBlockActionsProvider.openCamera(blockId: blockId)
            case .linkTo:
                textView?.shouldResignFirstResponder()
                router.showLinkTo { [weak self] details in
                    self?.actionHandler.addLink(targetDetails: details, blockId: blockInformation.id, route: .slashMenu)
                }
            }
        }
    }
    
    private func handleDate(_ newDate: Date, blockId: String) {
        Task {
            let details = try? await objectDateByTimestampService.objectDateByTimestamp(
                newDate.timeIntervalSince1970,
                spaceId: document.spaceId
            )
            guard let details else { return }
            actionHandler.addLink(targetDetails: details, blockId: blockId, route: .slashMenu)
        }
    }
    
    private func editorScreenData(objectId: String, objectType: ObjectType) -> EditorScreenData {
        if objectType.isListType {
            return .list(EditorListObject(objectId: objectId, spaceId: objectType.spaceId))
        } else {
            return .page(EditorPageObject(objectId: objectId, spaceId: objectType.spaceId))
        }
    }
    
    private func handleAlignment(_ alignment: SlashActionAlignment, blockIds: [String]) {
        actionHandler.setAlignment(alignment.blockAlignment, blockIds: blockIds, route: .slashMenu)
    }
    
    private func handleStyle(
        _ style: SlashActionStyle,
        attributedString: SafeNSAttributedString?,
        blockInformation: BlockInformation,
        modifiedStringHandler: (SafeNSAttributedString?) -> Void
    ) async throws {
        switch style {
        case .text:
            try await actionHandler.turnInto(.text, blockId: blockInformation.id, route: .slashMenu)
        case .title:
            try await actionHandler.turnInto(.header, blockId: blockInformation.id, route: .slashMenu)
        case .heading:
            try await actionHandler.turnInto(.header2, blockId: blockInformation.id, route: .slashMenu)
        case .subheading:
            try await actionHandler.turnInto(.header3, blockId: blockInformation.id, route: .slashMenu)
        case .highlighted:
            try await actionHandler.turnInto(.quote, blockId: blockInformation.id, route: .slashMenu)
        case .callout:
            try await actionHandler.turnInto(.callout, blockId: blockInformation.id, route: .slashMenu)
        case .checkbox:
            try await actionHandler.turnInto(.checkbox, blockId: blockInformation.id, route: .slashMenu)
        case .bulleted:
            try await actionHandler.turnInto(.bulleted, blockId: blockInformation.id, route: .slashMenu)
        case .numberedList:
            try await actionHandler.turnInto(.numbered, blockId: blockInformation.id, route: .slashMenu)
        case .toggle:
            try await actionHandler.turnInto(.toggle, blockId: blockInformation.id, route: .slashMenu)
            modifiedStringHandler(nil)
        case .bold:
            let modifiedAttributedString = try await actionHandler.toggleWholeBlockMarkup(
                attributedString,
                markup: .bold,
                info: blockInformation,
                route: .slashMenu
            )
            
            modifiedAttributedString.map(modifiedStringHandler)
        case .italic:
            let modifiedAttributedString = try await actionHandler.toggleWholeBlockMarkup(
                attributedString,
                markup: .italic,
                info: blockInformation,
                route: .slashMenu
            )
            
            modifiedAttributedString.map(modifiedStringHandler)
        case .strikethrough:
            let modifiedAttributedString = try await actionHandler.toggleWholeBlockMarkup(
                attributedString,
                markup: .strikethrough,
                info: blockInformation,
                route: .slashMenu
            )
            
            modifiedAttributedString.map(modifiedStringHandler)
        case .underline:
            let modifiedAttributedString = try await actionHandler.toggleWholeBlockMarkup(
                attributedString,
                markup: .underscored,
                info: blockInformation,
                route: .slashMenu
            )
            
            modifiedAttributedString.map(modifiedStringHandler)
        case .code:
            let modifiedAttributedString = try await actionHandler.toggleWholeBlockMarkup(
                attributedString,
                markup: .keyboard,
                info: blockInformation,
                route: .slashMenu
            )
            
            modifiedAttributedString.map(modifiedStringHandler)
        case .link:
            break
        }
    }
    
    private func handleActions(_ action: BlockAction, textView: UITextView?, blockId: String) async throws {
        switch action {
        case .delete:
            actionHandler.delete(blockIds: [blockId])
        case .duplicate:
            actionHandler.duplicate(blockId: blockId)
        case .moveTo:
            router.showMoveTo { [weak self] details in
                Task {
                    try await self?.actionHandler.moveToPage(blockIds: [blockId], pageId: details.id)
                }
            }
        case .copy:
            try await pasteboardService.copy(document: document, blocksIds: [blockId], selectedTextRange: NSRange())
        case .paste:
            textView?.paste(self)
        }
    }
    
    private func handleMediaAction(
        _ media: SlashActionMedia,
        textView: UITextView?,
        blockInformation: BlockInformation
    ) async throws {
        let blockId = try await actionHandler.addBlock(media.blockViewsType, blockId: blockInformation.id, blockText: textView?.attributedText.sendable())
        
        switch media {
        case .file:
            mediaBlockActionsProvider.openFilePicker(blockId: blockId)
        case .image:
            mediaBlockActionsProvider.openImagePicker(blockId: blockId)
        case .video:
            mediaBlockActionsProvider.openVideoPicker(blockId: blockId)
        case .scanDocuments:
            mediaBlockActionsProvider.openDocumentScanner(blockId: blockId)
        case .audio:
            mediaBlockActionsProvider.openAudioPicker(blockId: blockId)
        case .bookmark, .codeSnippet:
            break
        }
    }
}
