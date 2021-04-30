
import BlocksModels
import Combine

final class BlockMenuActionsHandlerImp: BlockMenuActionsHandler {
    
    private let marksPaneActionSubject: PassthroughSubject<MarksPane.Main.Action, Never>
    private let addBlockAndActionsSubject: PassthroughSubject<BlocksViews.Toolbar.UnderlyingAction, Never>
    
    init(marksPaneActionSubject: PassthroughSubject<MarksPane.Main.Action, Never>,
         turnIntoAndActionsSubject: PassthroughSubject<BlocksViews.Toolbar.UnderlyingAction, Never>) {
        self.marksPaneActionSubject = marksPaneActionSubject
        self.addBlockAndActionsSubject = turnIntoAndActionsSubject
    }
    
    func handle(action: BlockActionType) {
        switch action {
        case let .actions(action):
            self.handleActions(action)
        case let .alignment(alignmnet):
            self.handleAlignment(alignmnet)
        case let .style(style):
            self.handleStyle(style)
        case let .media(media):
            let type = BlocksViews.Toolbar.UnderlyingAction.BlockType.convert(media.blockViewsType)
            self.addBlockAndActionsSubject.send(.addBlock(type))
        case .objects:
            break
        case .relations:
            break
        case let .other(other):
            let type = BlocksViews.Toolbar.UnderlyingAction.BlockType.convert(other.blockViewsType)
            self.addBlockAndActionsSubject.send(.addBlock(type))
        case let .color(color):
            self.marksPaneActionSubject.send(.textColor(NSRange(), .setColor(color.color)))
        case let .background(color):
            self.marksPaneActionSubject.send(.backgroundColor(NSRange(), .setColor(color.color)))
        }
    }
    
    private func handleAlignment(_ alignment: BlockAlignmentAction) {
        switch alignment {
        case .left :
            self.marksPaneActionSubject.send(.style(.init(), .alignment(.left)))
        case .right:
            self.marksPaneActionSubject.send(.style(.init(), .alignment(.right)))
        case .center:
            self.marksPaneActionSubject.send(.style(.init(), .alignment(.center)))
        }
    }
    
    private func handleStyle(_ style: BlockStyleAction) {
        switch style {
        case .text:
            self.addBlockAndActionsSubject.send(.addBlock(.text(.text)))
        case .title:
            self.addBlockAndActionsSubject.send(.addBlock(.text(.h1)))
        case .heading:
            self.addBlockAndActionsSubject.send(.addBlock(.text(.h2)))
        case .subheading:
            self.addBlockAndActionsSubject.send(.addBlock(.text(.h3)))
        case .highlighted:
            self.addBlockAndActionsSubject.send(.addBlock(.text(.highlighted)))
        case .checkbox:
            self.addBlockAndActionsSubject.send(.addBlock(.list(.checkbox)))
        case .bulleted:
            self.addBlockAndActionsSubject.send(.addBlock(.list(.bulleted)))
        case .numberedList:
            self.addBlockAndActionsSubject.send(.addBlock(.list(.numbered)))
        case .toggle:
            self.addBlockAndActionsSubject.send(.addBlock(.list(.toggle)))
        case .bold:
            self.marksPaneActionSubject.send(.style(NSRange(), .fontStyle(.bold)))
        case .italic:
            self.marksPaneActionSubject.send(.style(NSRange(), .fontStyle(.italic)))
        case .breakthrough:
            self.marksPaneActionSubject.send(.style(NSRange(), .fontStyle(.strikethrough)))
        case .code:
            self.marksPaneActionSubject.send(.style(NSRange(), .fontStyle(.keyboard)))
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
}
