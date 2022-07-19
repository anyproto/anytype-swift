import SwiftUI
import BlocksModels

final class SetFiltersTextViewModel: ObservableObject {
    let isDecimalPad: Bool
    let onApplyText: (String) -> Void
    let onKeyboardHeightChange: (CGFloat) -> Void
    
    private var keyboardListenerHelper: KeyboardEventsListnerHelper?
    
    init(
        isDecimalPad: Bool,
        onApplyText: @escaping (String) -> Void,
        onKeyboardHeightChange: @escaping (CGFloat) -> Void)
    {
        self.isDecimalPad = isDecimalPad
        self.onApplyText = onApplyText
        self.onKeyboardHeightChange = onKeyboardHeightChange
        self.setupKeyboardListener()
    }

    func handleText(_ text: String) {
        onApplyText(text)
    }
    
    private func setupKeyboardListener() {
        let action: KeyboardEventsListnerHelper.Action = { [weak self] notification in
            guard
                let keyboardRect = notification.localKeyboardRect(for: UIResponder.keyboardFrameEndUserInfoKey)
            else { return }
            self?.onKeyboardHeightChange(keyboardRect.height)
        }

        let willHideAction: KeyboardEventsListnerHelper.Action = { [weak self] _ in
            self?.onKeyboardHeightChange(0)
        }

        self.keyboardListenerHelper = KeyboardEventsListnerHelper(
            willShowAction: action,
            willChangeFrame: action,
            willHideAction: willHideAction
        )
    }
}
