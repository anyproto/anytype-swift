import Foundation
import BlocksModels
import AnytypeCore
import UIKit

final class SlashMenuActionHandler {
    private let actionHandler: BlockActionHandlerProtocol
    private let router: EditorRouterProtocol
    private let pasteboardService: PasteboardServiceProtocol
    private weak var textView: UITextView?
    
    init(
        actionHandler: BlockActionHandlerProtocol,
        router: EditorRouterProtocol,
        pasteboardService: PasteboardServiceProtocol
    ) {
        self.actionHandler = actionHandler
        self.router = router
        self.pasteboardService = pasteboardService
    }
    
    func handle(_ action: SlashAction, textView: UITextView?, blockId: BlockId, selectedRange: NSRange) {
        switch action {
        case let .actions(action):
            handleActions(action, textView: textView, blockId: blockId, selectedRange: selectedRange)
        case let .alignment(alignmnet):
            handleAlignment(alignmnet, blockIds: [blockId])
        case let .style(style):
            handleStyle(style, blockId: blockId)
        case let .media(media):
            actionHandler.addBlock(media.blockViewsType, blockId: blockId, blockText: textView?.attributedText)
        case let .objects(action):
            switch action {
            case .linkTo:
                router.showLinkTo { [weak self] targetDetailsId, typeUrl in
                    self?.actionHandler.addLink(targetId: targetDetailsId, typeUrl: typeUrl, blockId: blockId)
                }
            case .objectType(let object):
                actionHandler
                    .createPage(targetId: blockId, type: .dynamic(object.id))
                    .flatMap { id in
                        AnytypeAnalytics.instance().logCreateObject(objectType: object.id, route: .powertool)

                        router.showPage(data: EditorScreenData(pageId: id, type: .page))
                    }
            }
        case let .relations(action):
            switch action {
            case .newRealtion:
                router.showAddNewRelationView() { [weak self] relation, isNew in
                    self?.actionHandler.addBlock(.relation(key: relation.id), blockId: blockId, blockText: textView?.attributedText)

                    AnytypeAnalytics.instance().logAddRelation(format: relation.format, isNew: isNew, type: .block)
                }
            case .relation(let relation):
                actionHandler.addBlock(.relation(key: relation.id), blockId: blockId, blockText: textView?.attributedText)
            }
        case let .other(other):
            switch other {
            case .table(let rowsCount, let columnsCount):
                actionHandler.createTable(blockId: blockId, rowsCount: rowsCount, columnsCount: columnsCount, blockText: textView?.attributedText)
            default:
                actionHandler.addBlock(other.blockViewsType, blockId: blockId, blockText: textView?.attributedText)
            }
        case let .color(color):
            actionHandler.setTextColor(color, blockIds: [blockId])
        case let .background(color):
            actionHandler.setBackgroundColor(color, blockIds: [blockId])
        }
    }
    
    func changeText(_ text: NSAttributedString, info: BlockInformation) {
        actionHandler.changeTextForced(text, blockId: info.id)
    }
    
    private func handleAlignment(_ alignment: SlashActionAlignment, blockIds: [BlockId]) {
        switch alignment {
        case .left :
            actionHandler.setAlignment(.left, blockIds: blockIds)
        case .right:
            actionHandler.setAlignment(.right, blockIds: blockIds)
        case .center:
            actionHandler.setAlignment(.center, blockIds: blockIds)
        }
    }
    
    private func handleStyle(_ style: SlashActionStyle, blockId: BlockId) {
        switch style {
        case .text:
            actionHandler.turnInto(.text, blockId: blockId)
        case .title:
            actionHandler.turnInto(.header, blockId: blockId)
        case .heading:
            actionHandler.turnInto(.header2, blockId: blockId)
        case .subheading:
            actionHandler.turnInto(.header3, blockId: blockId)
        case .highlighted:
            actionHandler.turnInto(.quote, blockId: blockId)
        case .callout:
            actionHandler.turnInto(.callout, blockId: blockId)
        case .checkbox:
            actionHandler.turnInto(.checkbox, blockId: blockId)
        case .bulleted:
            actionHandler.turnInto(.bulleted, blockId: blockId)
        case .numberedList:
            actionHandler.turnInto(.numbered, blockId: blockId)
        case .toggle:
            actionHandler.turnInto(.toggle, blockId: blockId)
        case .bold:
            actionHandler.toggleWholeBlockMarkup(.bold, blockId: blockId)
        case .italic:
            actionHandler.toggleWholeBlockMarkup(.italic, blockId: blockId)
        case .strikethrough:
            actionHandler.toggleWholeBlockMarkup(.strikethrough, blockId: blockId)
        case .code:
            actionHandler.toggleWholeBlockMarkup(.keyboard, blockId: blockId)
        case .link:
            break
        }
    }
    
    private func handleActions(_ action: BlockAction, textView: UITextView?, blockId: BlockId, selectedRange: NSRange) {
        switch action {
        case .delete:
            actionHandler.delete(blockIds: [blockId])
        case .duplicate:
            actionHandler.duplicate(blockId: blockId)
        case .moveTo:
            router.showMoveTo { [weak self] pageId in
                self?.actionHandler.moveToPage(blockId: blockId, pageId: pageId)
            }
        case .copy:
            pasteboardService.copy(blocksIds: [blockId], selectedTextRange: NSRange())
        case .paste:
            textView?.paste(self)
        }
    }
}
