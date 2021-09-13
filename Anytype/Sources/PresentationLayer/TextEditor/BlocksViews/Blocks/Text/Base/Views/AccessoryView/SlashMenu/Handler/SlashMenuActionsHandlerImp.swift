import BlocksModels
import Combine
import ProtobufMessages
import UIKit

final class SlashMenuActionsHandlerImp {
    private var initialCaretPosition: UITextPosition?
    private weak var textView: UITextView?
    private var middwareEventsSubscription: AnyCancellable?
    
    private let blockActionHandler: EditorActionHandlerProtocol
    
    init(blockActionHandler: EditorActionHandlerProtocol) {
        self.blockActionHandler = blockActionHandler
    }
}

extension SlashMenuActionsHandlerImp: SlashMenuActionsHandler {
    
    func handle(action: BlockActionType) {
        removeSlashMenuText()
        
        switch action {
        case let .actions(action):
            handleActions(action)
        case let .alignment(alignmnet):
            handleAlignment(alignmnet)
        case let .style(style):
            handleStyle(style)
        case let .media(media):
            blockActionHandler.handleActionForFirstResponder(.addBlock(media.blockViewsType))
        case .objects:
            blockActionHandler.turnIntoPage(blockId: .firstResponder) { [weak self] blockId in
                blockId.flatMap { self?.show(blockId: $0) }
            }
        case .relations:
            break
        case let .other(other):
            blockActionHandler.handleActionForFirstResponder(.addBlock(other.blockViewsType))
        case let .color(color):
            blockActionHandler.handleActionForFirstResponder(
                .setTextColor(color)
            )
        case let .background(color):
            blockActionHandler.handleActionForFirstResponder(
                .setBackgroundColor(color)
            )
        }
    }
    
    func didShowMenuView(from textView: UITextView) {
        self.textView = textView
        guard let caretPosition = textView.caretPosition() else { return }
        // -1 because in text "Hello, everyone/" we want to store position before slash, not after
        initialCaretPosition = textView.position(from: caretPosition, offset: -1)
    }
}

private extension SlashMenuActionsHandlerImp {
    private func handleAlignment(_ alignment: BlockAlignmentAction) {
        switch alignment {
        case .left :
            blockActionHandler.handleActionForFirstResponder(
                .setAlignment(.left)
            )
        case .right:
            blockActionHandler.handleActionForFirstResponder(
                .setAlignment(.right)
            )
        case .center:
            blockActionHandler.handleActionForFirstResponder(
                .setAlignment(.center)
            )
        }
    }
    
    private func handleStyle(_ style: BlockStyleAction) {
        switch style {
        case .text:
            blockActionHandler.handleActionForFirstResponder(.turnIntoBlock(.text(.text)))
        case .title:
            blockActionHandler.handleActionForFirstResponder(.turnIntoBlock(.text(.header)))
        case .heading:
            blockActionHandler.handleActionForFirstResponder(.turnIntoBlock(.text(.header2)))
        case .subheading:
            blockActionHandler.handleActionForFirstResponder(.turnIntoBlock(.text(.header3)))
        case .highlighted:
            blockActionHandler.handleActionForFirstResponder(.turnIntoBlock(.text(.quote)))
        case .checkbox:
            blockActionHandler.handleActionForFirstResponder(.turnIntoBlock(.text(.checkbox)))
        case .bulleted:
            blockActionHandler.handleActionForFirstResponder(.turnIntoBlock(.text(.bulleted)))
        case .numberedList:
            blockActionHandler.handleActionForFirstResponder(.turnIntoBlock(.text(.numbered)))
        case .toggle:
            blockActionHandler.handleActionForFirstResponder(.turnIntoBlock(.text(.toggle)))
        case .bold:
            blockActionHandler.handleActionForFirstResponder(.toggleWholeBlockMarkup(.bold))
        case .italic:
            blockActionHandler.handleActionForFirstResponder(.toggleWholeBlockMarkup(.italic))
        case .strikethrough:
            blockActionHandler.handleActionForFirstResponder(.toggleWholeBlockMarkup(.strikethrough))
        case .code:
            blockActionHandler.handleActionForFirstResponder(.toggleWholeBlockMarkup(.keyboard))
        case .link:
            break
        }
    }
    
    private func handleActions(_ action: BlockAction) {
        switch action {
        case .delete:
            blockActionHandler.handleActionForFirstResponder(.delete)
        case .duplicate:
            blockActionHandler.handleActionForFirstResponder(.duplicate)
            
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
              let currentPosition = textView.caretPosition(),
              let textRange = textView.textRange(from: initialCaretPosition, to: currentPosition) else {
            return
        }
        textView.replace(textRange, withText: "")
    }
    
    private func show(blockId: BlockId) {
        // We add delay manualy to have some visual delay
        // between selecting "Page" in slash menu
        // and transfering to newly created page
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.blockActionHandler.showPage(blockId: .provided(blockId))
        }
    }
}
