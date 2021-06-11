
import BlocksModels
import Combine
import UIKit

final class BlockMenuActionsHandlerImp {
    
    private let marksPaneActionSubject: PassthroughSubject<MarksPane.Main.Action, Never>
    private let addBlockAndActionsSubject: PassthroughSubject<BlocksViews.Toolbar.UnderlyingAction, Never>
    private var initialCaretPosition: UITextPosition?
    private weak var textView: UITextView?
    
    init(marksPaneActionSubject: PassthroughSubject<MarksPane.Main.Action, Never>,
         addBlockAndActionsSubject: PassthroughSubject<BlocksViews.Toolbar.UnderlyingAction, Never>) {
        self.marksPaneActionSubject = marksPaneActionSubject
        self.addBlockAndActionsSubject = addBlockAndActionsSubject
    }
    
    private func handleAlignment(_ alignment: BlockAlignmentAction) {
        switch alignment {
        case .left :
            marksPaneActionSubject.send(.style(.alignment(.left)))
        case .right:
            marksPaneActionSubject.send(.style(.alignment(.right)))
        case .center:
            marksPaneActionSubject.send(.style(.alignment(.center)))
        }
    }
    
    private func handleStyle(_ style: BlockStyleAction) {
        switch style {
        case .text:
            self.addBlockAndActionsSubject.send(.turnIntoBlock(.text(.text)))
        case .title:
            self.addBlockAndActionsSubject.send(.turnIntoBlock(.text(.h1)))
        case .heading:
            self.addBlockAndActionsSubject.send(.turnIntoBlock(.text(.h2)))
        case .subheading:
            self.addBlockAndActionsSubject.send(.turnIntoBlock(.text(.h3)))
        case .highlighted:
            self.addBlockAndActionsSubject.send(.turnIntoBlock(.text(.highlighted)))
        case .checkbox:
            self.addBlockAndActionsSubject.send(.turnIntoBlock(.list(.checkbox)))
        case .bulleted:
            self.addBlockAndActionsSubject.send(.turnIntoBlock(.list(.bulleted)))
        case .numberedList:
            self.addBlockAndActionsSubject.send(.turnIntoBlock(.list(.numbered)))
        case .toggle:
            self.addBlockAndActionsSubject.send(.turnIntoBlock(.list(.toggle)))
        case .bold:
            self.marksPaneActionSubject.send(.style(.fontStyle(.bold(true))))
        case .italic:
            self.marksPaneActionSubject.send(.style(.fontStyle(.italic(true))))
        case .breakthrough:
            self.marksPaneActionSubject.send(.style(.fontStyle(.strikethrough(true))))
        case .code:
            self.marksPaneActionSubject.send(.style(.fontStyle(.keyboard(true))))
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
