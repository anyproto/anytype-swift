import Foundation
import BlocksModels


final class SlashMenuActionHandler {
    private let actionHandler: EditorActionHandlerProtocol
    private let router: EditorRouterProtocol
    
    init(
        actionHandler: EditorActionHandlerProtocol,
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
            handleAlignment(alignmnet)
        case let .style(style):
            handleStyle(style)
        case let .media(media):
            actionHandler.handleActionForFirstResponder(.addBlock(media.blockViewsType))
        case .objects(let action):
            switch action {
            case .linkTo:
                router.showLinkTo { [weak self] targetDetailsId in
                    self?.actionHandler.handleAction(.addLink(targetDetailsId), blockId: blockId)
                }
            case .objectType(let object):
                actionHandler.createPage(targetId: blockId, type: .dynamic(object.id))
                    .flatMap { actionHandler.showPage(blockId: .provided($0)) }
            }
        case .relations:
            break
        case let .other(other):
            actionHandler.handleActionForFirstResponder(.addBlock(other.blockViewsType))
        case let .color(color):
            actionHandler.handleActionForFirstResponder(
                .setTextColor(color)
            )
        case let .background(color):
            actionHandler.handleActionForFirstResponder(
                .setBackgroundColor(color)
            )
        }
    }
    
    func changeText(_ text: NSAttributedString, block: BlockModelProtocol) {
        actionHandler.handleAction(
            .textView(
                action: .changeText(text),
                block: block
            ), blockId: block.information.id
        )
    }
    
    private func handleAlignment(_ alignment: SlashActionAlignment) {
        switch alignment {
        case .left :
            actionHandler.handleActionForFirstResponder(
                .setAlignment(.left)
            )
        case .right:
            actionHandler.handleActionForFirstResponder(
                .setAlignment(.right)
            )
        case .center:
            actionHandler.handleActionForFirstResponder(
                .setAlignment(.center)
            )
        }
    }
    
    private func handleStyle(_ style: SlashActionStyle) {
        switch style {
        case .text:
            actionHandler.handleActionForFirstResponder(.turnIntoBlock(.text(.text)))
        case .title:
            actionHandler.handleActionForFirstResponder(.turnIntoBlock(.text(.header)))
        case .heading:
            actionHandler.handleActionForFirstResponder(.turnIntoBlock(.text(.header2)))
        case .subheading:
            actionHandler.handleActionForFirstResponder(.turnIntoBlock(.text(.header3)))
        case .highlighted:
            actionHandler.handleActionForFirstResponder(.turnIntoBlock(.text(.quote)))
        case .checkbox:
            actionHandler.handleActionForFirstResponder(.turnIntoBlock(.text(.checkbox)))
        case .bulleted:
            actionHandler.handleActionForFirstResponder(.turnIntoBlock(.text(.bulleted)))
        case .numberedList:
            actionHandler.handleActionForFirstResponder(.turnIntoBlock(.text(.numbered)))
        case .toggle:
            actionHandler.handleActionForFirstResponder(.turnIntoBlock(.text(.toggle)))
        case .bold:
            actionHandler.handleActionForFirstResponder(.toggleWholeBlockMarkup(.bold))
        case .italic:
            actionHandler.handleActionForFirstResponder(.toggleWholeBlockMarkup(.italic))
        case .strikethrough:
            actionHandler.handleActionForFirstResponder(.toggleWholeBlockMarkup(.strikethrough))
        case .code:
            actionHandler.handleActionForFirstResponder(.toggleWholeBlockMarkup(.keyboard))
        case .link:
            break
        }
    }
    
    private func handleActions(_ action: BlockAction, blockId: BlockId) {
        switch action {
        case .delete:
            actionHandler.handleActionForFirstResponder(.delete)
        case .duplicate:
            actionHandler.handleActionForFirstResponder(.duplicate)
        case .moveTo:
            router.showMoveTo { [weak self] targetId in
                self?.actionHandler.handleAction(
                    .moveTo(targetId: targetId), blockId: blockId
                )
            }
//        case .copy, .paste, .move, .moveTo:
//            break
        }
    }
}
