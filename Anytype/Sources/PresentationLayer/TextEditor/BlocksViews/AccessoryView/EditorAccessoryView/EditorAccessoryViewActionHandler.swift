import UIKit

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


final class EditorAccessoryViewActionHandler {
    private weak var delegate: TextViewDelegate?
    weak var switcher: AccessoryViewSwitcherProtocol?
    weak var customTextView: CustomTextView?
    
    init(delegate: TextViewDelegate) {
        self.delegate = delegate
    }
    
    func handle(_ action: EditorAccessoryViewAction) {
        guard let customTextView = customTextView, let switcher = switcher else {
            return
        }

        switch action {
        case .slashMenu:
            customTextView.textView.insertStringAfterCaret(
                switcher.textToTriggerSlashViewDisplay
            )
            switcher.showSlashMenuView(textView: customTextView.textView)
        case .showStyleMenu:
            delegate?.didReceiveAction(.showStyleMenu)

        case .keyboardDismiss:
            UIApplication.shared.hideKeyboard()
        case .mention:
            customTextView.textView.insertStringAfterCaret(
                switcher.textToTriggerMentionViewDisplay
            )
            switcher.showMentionsView(textView: customTextView.textView)
        }
    }
}
