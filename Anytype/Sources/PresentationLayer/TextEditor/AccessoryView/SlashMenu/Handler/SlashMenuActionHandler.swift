import Foundation
import BlocksModels
import AnytypeCore

final class SlashMenuActionHandler {
    private let actionHandler: BlockActionHandlerProtocol
    private let router: EditorRouterProtocol
    
    init(
        actionHandler: BlockActionHandlerProtocol,
        router: EditorRouterProtocol
    ) {
        self.actionHandler = actionHandler
        self.router = router
    }
    
    func handle(_ action: SlashAction, blockId: BlockId) {
        switch action {
        case let .actions(action):
            handleActions(action, blockId: blockId)
        case let .alignment(alignmnet):
            handleAlignment(alignmnet, blockId: blockId)
        case let .style(style):
            handleStyle(style, blockId: blockId)
        case let .media(media):
            actionHandler.addBlock(media.blockViewsType, blockId: blockId)
        case let .objects(action):
            switch action {
            case .linkTo:
                router.showLinkTo { [weak self] targetDetailsId in
                    self?.actionHandler.addLink(targetId: targetDetailsId, blockId: blockId)
                }
            case .objectType(let object):
                actionHandler
                    .createPage(targetId: blockId, type: .dynamic(object.id.value))
                    .flatMap { $0.asAnytypeId }
                    .flatMap {
                        router.showPage(data: EditorScreenData(pageId: $0, type: .page))
                    }
            }
        case let .relations(action):
            switch action {
            case .newRealtion:
                router.showAddNewRelationView() { [weak self] relation in
                    self?.actionHandler.addBlock(.relation(key: relation.id), blockId: blockId)
                }
            case .relation(let relation):
                actionHandler.addBlock(.relation(key: relation.id), blockId: blockId)
            }
        case let .other(other):
            actionHandler.addBlock(other.blockViewsType, blockId: blockId)
        case let .color(color):
            actionHandler.setTextColor(color, blockId: blockId)
        case let .background(color):
            actionHandler.setBackgroundColor(color, blockId: blockId)
        }
    }
    
    func changeText(_ text: NSAttributedString, info: BlockInformation) {
        actionHandler.changeTextForced(text, blockId: info.id.value)
    }
    
    private func handleAlignment(_ alignment: SlashActionAlignment, blockId: BlockId) {
        switch alignment {
        case .left :
            actionHandler.setAlignment(.left, blockId: blockId)
        case .right:
            actionHandler.setAlignment(.right, blockId: blockId)
        case .center:
            actionHandler.setAlignment(.center, blockId: blockId)
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
    
    private func handleActions(_ action: BlockAction, blockId: BlockId) {
        switch action {
        case .delete:
            actionHandler.delete(blockId: blockId)
        case .duplicate:
            actionHandler.duplicate(blockId: blockId)
        case .moveTo:
            router.showMoveTo { [weak self] pageId in
                self?.actionHandler.moveToPage(blockId: blockId, pageId: pageId)
            }
        }
    }
}
