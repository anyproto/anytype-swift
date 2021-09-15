import UIKit
import BlocksModels

enum EditorAccessoryViewAction {
    /// Slash button pressed
    case slashMenu
    /// Done button pressed
    case keyboardDismiss
    /// Show bottom sheet style menu
    case showStyleMenu
    /// Show mention menu
    case mention
}


final class EditorAccessoryViewModel {
    var information: BlockInformation?
    
    weak var customTextView: CustomTextView?
    weak var delegate: EditorAccessoryViewDelegate?
    
    private let router: EditorRouter
    
    init(router: EditorRouter) {
        self.router = router
    }
    
    func handle(_ action: EditorAccessoryViewAction) {
        guard let customTextView = customTextView, let delegate = delegate else {
            return
        }

        switch action {
        case .slashMenu:
            customTextView.textView.insertStringAfterCaret("/")
            delegate.showSlashMenuView(textView: customTextView.textView)
        case .showStyleMenu:
            information.flatMap {
                router.showStyleMenu(information: $0)
            }
        case .keyboardDismiss:
            UIApplication.shared.hideKeyboard()
        case .mention:
            customTextView.textView.insertStringAfterCaret("@")
            delegate.showMentionsView(textView: customTextView.textView)
        }
    }
}
