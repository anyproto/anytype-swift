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


class EditorAccessoryViewActionHandler {
    weak var delegate: TextViewUserInteractionProtocol?
    
    private let switcher: AccessoryViewSwitcher
    private weak var customTextView: CustomTextView?
    
    init(
        customTextView: CustomTextView,
        switcher: AccessoryViewSwitcher,
        delegate: TextViewUserInteractionProtocol?
    ) {
        self.customTextView = customTextView
        self.switcher = switcher
        self.delegate = delegate
    }
    
    func handle(_ action: EditorAccessoryViewAction) {
        guard let customTextView = customTextView else {
            return
        }
        
        switcher.switchInputs(customTextView: customTextView)

        switch action {
        case .slashMenu:
            customTextView.textView.insertStringToAttributedString(
                switcher.textToTriggerActionsViewDisplay
            )
            switcher.showAccessoryView(
                accessoryView: customTextView.slashMenuView,
                textView: customTextView.textView
            )
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
            switcher.showAccessoryView(
                accessoryView: customTextView.mentionView,
                textView: customTextView.textView
            )
        }
    }
}
