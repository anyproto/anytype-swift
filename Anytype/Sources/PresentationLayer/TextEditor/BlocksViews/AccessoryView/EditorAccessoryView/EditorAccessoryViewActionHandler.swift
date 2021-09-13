import UIKit

enum EditorAccessoryViewAction {
    /// Slash button pressed
    case slashMenu
    /// Multiselect button pressed
    case multiActionMenu
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
            customTextView.textView.insertStringToAttributedStringAfterCaret(
                switcher.textToTriggerSlashViewDisplay
            )
            switcher.showSlashMenuView(textView: customTextView.textView)
        case .multiActionMenu:
            delegate?.didReceiveAction(
                .showMultiActionMenuAction
            )

        case .showStyleMenu:
            delegate?.didReceiveAction(.showStyleMenu)

        case .keyboardDismiss:
            UIApplication.shared.hideKeyboard()
        case .mention:
            customTextView.textView.insertStringToAttributedStringAfterCaret(
                switcher.textToTriggerMentionViewDisplay
            )
            switcher.showMentionsView(textView: customTextView.textView)
        }
    }
}
