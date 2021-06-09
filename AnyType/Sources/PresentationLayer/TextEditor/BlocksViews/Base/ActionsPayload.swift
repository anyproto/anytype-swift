import BlocksModels
import UIKit

/// This AactionsPayload describes all actions that user can do with BlocksViewsModels.
/// For example, user can press long-tap and active toolbar.
/// Or user could interact with text view.
/// Possibly, that we need to separate text view actions.
enum ActionsPayload {
    struct Toolbar {
        let model: BlockActiveRecordModelProtocol
        let action: BlocksViews.Toolbar.UnderlyingAction
    }

    struct MarksPaneHolder {
        let model: BlockActiveRecordModelProtocol
        let action: MarksPane.Main.Action
    }

    /// For backward compatibility.
    struct TextBlocksViewsUserInteraction {
        let model: BlockActiveRecordModelProtocol
        let action: TextBlockUserInteraction
    }

    /// For seamless usage of UserAction as "Payload"
    struct UserAction {
        let model: BlockActiveRecordModelProtocol
        let action: BlocksViews.UserAction
    }

    /// Text blocks draft.
    /// It should hold also toggle from `TextBlocksViewsUserInteraction`.
    /// Name it properly.
    struct TextBlockViewModelPayload {
        enum Action {
            case text(NSAttributedString)
            case alignment(NSTextAlignment)
            case checked(Bool)
        }

        var model: BlockActiveRecordModelProtocol
        var action: Action
    }

    case toolbar(Toolbar)
    case marksPane(MarksPaneHolder)
    case textView(TextBlocksViewsUserInteraction)
    case userAction(UserAction)
    /// show code language view
    case showCodeLanguageView(languages: [String], completion: (String) -> Void)
    /// show style menu
    case showStyleMenu(blockModel: BlockModelProtocol, blockViewModel: BaseBlockViewModel)
    /// tell that block become first responder
    case becomeFirstResponder(BlockModelProtocol)
}
