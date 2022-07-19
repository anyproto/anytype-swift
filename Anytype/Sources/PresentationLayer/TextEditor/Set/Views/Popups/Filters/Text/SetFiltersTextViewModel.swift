import SwiftUI
import BlocksModels

final class SetFiltersTextViewModel: ObservableObject {
    let keyboardType: UIKeyboardType
    let onApplyText: (String) -> Void
    let onKeyboardHeightChange: (CGFloat) -> Void
    
    private var keyboardListenerHelper: KeyboardEventsListnerHelper?
    
    init(
        filter: SetFilter,
        onApplyText: @escaping (String) -> Void,
        onKeyboardHeightChange: @escaping (CGFloat) -> Void)
    {
        self.keyboardType = Self.keybordType(for: filter)
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
    
    private static func keybordType(for filter: SetFilter) -> UIKeyboardType {
        switch filter.metadata.format {
        case .number: return .decimalPad
        case .url: return .URL
        case .email: return .emailAddress
        case .phone: return .phonePad
        default: return .default
        }
    }
}
