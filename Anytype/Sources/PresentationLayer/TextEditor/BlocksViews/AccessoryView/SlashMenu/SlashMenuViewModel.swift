import BlocksModels
import Combine
import ProtobufMessages
import UIKit

final class SlashMenuViewModel {
    var block: BlockModelProtocol?
    
    private var initialCaretPosition: UITextPosition?
    private weak var textView: UITextView?
    private var middwareEventsSubscription: AnyCancellable?
    
    private let actionHandler: EditorActionHandlerProtocol
    
    init(actionHandler: EditorActionHandlerProtocol) {
        self.actionHandler = actionHandler
    }
    
    func handle(action: SlashAction) {
        removeSlashMenuText()
        
        switch action {
        case let .actions(action):
            handleActions(action)
        case let .alignment(alignmnet):
            handleAlignment(alignmnet)
        case let .style(style):
            handleStyle(style)
        case let .media(media):
            actionHandler.handleActionForFirstResponder(.addBlock(media.blockViewsType))
        case .objects:
            actionHandler.turnIntoPage(blockId: .firstResponder) { [weak self] blockId in
                blockId.flatMap { self?.show(blockId: $0) }
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
    
    func didShowMenuView(from textView: UITextView) {
        self.textView = textView
        guard let caretPosition = textView.caretPosition else { return }
        // -1 because in text "Hello, everyone/" we want to store position before slash, not after
        initialCaretPosition = textView.position(from: caretPosition, offset: -1)
    }

    private func handleAlignment(_ alignment: BlockAlignmentAction) {
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
    
    private func handleStyle(_ style: BlockStyleAction) {
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
    
    private func handleActions(_ action: BlockAction) {
        switch action {
        case .delete:
            actionHandler.handleActionForFirstResponder(.delete)
        case .duplicate:
            actionHandler.handleActionForFirstResponder(.duplicate)
            
        case .cleanStyle, .copy, .paste, .move, .moveTo:
            break
        }
    }
    
    private func removeSlashMenuText() {
        // After we select any action from actions menu we must delete /symbol
        // and all text which was typed after /
        //
        // We create text range from two text positions and replace text in
        // this range with empty string
        guard let initialCaretPosition = initialCaretPosition,
              let textView = textView,
              let currentPosition = textView.caretPosition,
              let textRange = textView.textRange(from: initialCaretPosition, to: currentPosition),
              let block = block else {
            return
        }
        textView.replace(textRange, withText: "")
        
        guard let text = textView.attributedText else { return }
        actionHandler.handleAction(
            .textView(
                action: .changeText(text),
                block: block
            ), blockId: block.information.id
        )
    }
    
    private func show(blockId: BlockId) {
        // We add delay manualy to have some visual delay
        // between selecting "Page" in slash menu
        // and transfering to newly created page
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.actionHandler.showPage(blockId: .provided(blockId))
        }
    }
}
