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
    private weak var delegate: TextViewUserInteractionProtocol?
    weak var switcher: AccessoryViewSwitcher?
    weak var customTextView: CustomTextView?
    
    init(
        delegate: TextViewUserInteractionProtocol?
    ) {
        self.delegate = delegate
    }
    
    func handle(_ action: EditorAccessoryViewAction) {
        guard let customTextView = customTextView, let switcher = switcher else {
            return
        }
        
        switcher.switchInputs(textView: customTextView.textView)

        switch action {
        case .slashMenu:
            customTextView.textView.insertStringToAttributedString(
                switcher.textToTriggerActionsViewDisplay
            )
            switcher.showSlashMenuView(textView: customTextView.textView)
        case .multiActionMenu:
            delegate?.didReceiveAction(
                .showMultiActionMenuAction
            )

        case .showStyleMenu:
            delegate?.didReceiveAction(.showStyleMenu)

        case .keyboardDismiss:
            UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
        case .mention:
            customTextView.textView.insertStringToAttributedString(
                switcher.textToTriggerMentionViewDisplay
            )
            switcher.showMentionsView(textView: customTextView.textView)
        }
    }
}
