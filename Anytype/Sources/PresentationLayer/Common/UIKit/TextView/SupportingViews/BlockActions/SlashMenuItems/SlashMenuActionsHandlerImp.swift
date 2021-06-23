import BlocksModels
import Combine
import UIKit

final class SlashMenuActionsHandlerImp {
    
    private var initialCaretPosition: UITextPosition?
    private weak var textView: UITextView?
    private weak var blockActionHandler: NewBlockActionHandler?
    
    init(blockActionHandler: NewBlockActionHandler?) {
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
            blockActionHandler?.handleActionForFirstResponder(.addBlock(media.blockViewsType))
        case .objects:
            addBlockAndActionsSubject.send(.addBlock(.objects(.page)))
        case .relations:
            break
        case let .other(other):
            blockActionHandler?.handleActionForFirstResponder(.addBlock(other.blockViewsType))
        case let .color(color):
            blockActionHandler?.handleActionForFirstResponder(
                .setTextColor(color)
            )
        case let .background(color):
            blockActionHandler?.handleActionForFirstResponder(
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
            blockActionHandler?.handleActionForFirstResponder(
                .setAlignment(.left)
            )
        case .right:
            blockActionHandler?.handleActionForFirstResponder(
                .setAlignment(.right)
            )
        case .center:
            blockActionHandler?.handleActionForFirstResponder(
                .setAlignment(.center)
            )
        }
    }
    
    private func handleStyle(_ style: BlockStyleAction) {
        switch style {
        case .text:
            blockActionHandler?.handleActionForFirstResponder(.turnIntoBlock(.text(.text)))
        case .title:
            blockActionHandler?.handleActionForFirstResponder(.turnIntoBlock(.text(.h1)))
        case .heading:
            blockActionHandler?.handleActionForFirstResponder(.turnIntoBlock(.text(.h2)))
        case .subheading:
            blockActionHandler?.handleActionForFirstResponder(.turnIntoBlock(.text(.h3)))
        case .highlighted:
            blockActionHandler?.handleActionForFirstResponder(.turnIntoBlock(.text(.highlighted)))
        case .checkbox:
            blockActionHandler?.handleActionForFirstResponder(.turnIntoBlock(.list(.checkbox)))
        case .bulleted:
            blockActionHandler?.handleActionForFirstResponder(.turnIntoBlock(.list(.bulleted)))
        case .numberedList:
            blockActionHandler?.handleActionForFirstResponder(.turnIntoBlock(.list(.numbered)))
        case .toggle:
            blockActionHandler?.handleActionForFirstResponder(.turnIntoBlock(.list(.toggle)))
        case .bold:
            blockActionHandler?.handleActionForFirstResponder(.toggleFontStyle(.bold))
        case .italic:
            blockActionHandler?.handleActionForFirstResponder(.toggleFontStyle(.italic))
        case .breakthrough:
            blockActionHandler?.handleActionForFirstResponder(.toggleFontStyle(.strikethrough))
        case .code:
            blockActionHandler?.handleActionForFirstResponder(.toggleFontStyle(.keyboard))
        case .link:
            break
        }
    }
    
    private func handleActions(_ action: BlockAction) {
        switch action {
        case .delete:
            blockActionHandler?.handleActionForFirstResponder(.delete)
        case .duplicate:
            blockActionHandler?.handleActionForFirstResponder(.duplicate)
            
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
}
