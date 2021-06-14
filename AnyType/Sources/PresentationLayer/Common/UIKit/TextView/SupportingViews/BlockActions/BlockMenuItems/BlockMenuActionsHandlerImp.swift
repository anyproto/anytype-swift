
import BlocksModels
import Combine
import UIKit

final class BlockMenuActionsHandlerImp {
    
    private let marksPaneActionSubject: PassthroughSubject<MarksPaneMainAttribute, Never>
    private let addBlockAndActionsSubject: PassthroughSubject<BlocksViews.Toolbar.UnderlyingAction, Never>
    private var initialCaretPosition: UITextPosition?
    private weak var textView: UITextView?
    
    init(marksPaneActionSubject: PassthroughSubject<MarksPaneMainAttribute, Never>,
         addBlockAndActionsSubject: PassthroughSubject<BlocksViews.Toolbar.UnderlyingAction, Never>) {
        self.marksPaneActionSubject = marksPaneActionSubject
        self.addBlockAndActionsSubject = addBlockAndActionsSubject
    }
    
    private func handleAlignment(_ alignment: BlockAlignmentAction) {
        switch alignment {
        case .left :
            marksPaneActionSubject.send(.alignment(.left))
        case .right:
            marksPaneActionSubject.send(.alignment(.right))
        case .center:
            marksPaneActionSubject.send(.alignment(.center))
        }
    }
    
    private func handleStyle(_ style: BlockStyleAction) {
        switch style {
        case .text:
            addBlockAndActionsSubject.send(.turnIntoBlock(.text(.text)))
        case .title:
            addBlockAndActionsSubject.send(.turnIntoBlock(.text(.h1)))
        case .heading:
            addBlockAndActionsSubject.send(.turnIntoBlock(.text(.h2)))
        case .subheading:
            addBlockAndActionsSubject.send(.turnIntoBlock(.text(.h3)))
        case .highlighted:
            addBlockAndActionsSubject.send(.turnIntoBlock(.text(.highlighted)))
        case .checkbox:
            addBlockAndActionsSubject.send(.turnIntoBlock(.list(.checkbox)))
        case .bulleted:
            addBlockAndActionsSubject.send(.turnIntoBlock(.list(.bulleted)))
        case .numberedList:
            addBlockAndActionsSubject.send(.turnIntoBlock(.list(.numbered)))
        case .toggle:
            addBlockAndActionsSubject.send(.turnIntoBlock(.list(.toggle)))
        case .bold:
            marksPaneActionSubject.send(.fontStyle(.bold))
        case .italic:
            marksPaneActionSubject.send(.fontStyle(.italic))
        case .breakthrough:
            marksPaneActionSubject.send(.fontStyle(.strikethrough))
        case .code:
            marksPaneActionSubject.send(.fontStyle(.keyboard))
        case .link:
            break
        }
    }
    
    private func handleActions(_ action: BlockAction) {
        switch action {
        case .cleanStyle:
            break
        case .delete:
            self.addBlockAndActionsSubject.send(.editBlock(.delete))
        case .duplicate:
            self.addBlockAndActionsSubject.send(.editBlock(.duplicate))
        case .copy:
            break
        case .paste:
            break
        case .move:
            break
        case .moveTo:
            break
        }
    }
    
    private func removeTextAfterInitialAndCurrentCaretPositions() {
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

extension BlockMenuActionsHandlerImp: BlockMenuActionsHandler {
    
    func handle(action: BlockActionType) {
        removeTextAfterInitialAndCurrentCaretPositions()
        switch action {
        case let .actions(action):
            handleActions(action)
        case let .alignment(alignmnet):
            handleAlignment(alignmnet)
        case let .style(style):
            handleStyle(style)
        case let .media(media):
            addBlockAndActionsSubject.send(.addBlock(media.blockViewsType))
        case .objects:
            break
        case .relations:
            break
        case let .other(other):
            addBlockAndActionsSubject.send(.addBlock(other.blockViewsType))
        case let .color(color):
            marksPaneActionSubject.send(.textColor(color.color))
        case let .background(color):
            marksPaneActionSubject.send(.backgroundColor(color.color))
        }
    }
    
    func didShowMenuView(from textView: UITextView) {
        self.textView = textView
        guard let caretPosition = textView.caretPosition() else { return }
        // -1 because in text "Hello, everyone/" we want to store position before slash, not after
        initialCaretPosition = textView.position(from: caretPosition, offset: -1)
    }
}
