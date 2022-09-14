import SwiftUI
import BlocksModels

final class SetFiltersTextViewModel: ObservableObject {
    @Published var input = ""
    
    let keyboardType: UIKeyboardType
    let onApplyText: (String) -> Void
    let onKeyboardHeightChange: (CGFloat) -> Void
    
    private var keyboardListenerHelper: KeyboardEventsListnerHelper?
    
    private static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ""
        return formatter
    }()
    
    init(
        filter: SetFilter,
        onApplyText: @escaping (String) -> Void,
        onKeyboardHeightChange: @escaping (CGFloat) -> Void)
    {
        self.input = Self.initialValue(from: filter)
        self.keyboardType = Self.keybordType(for: filter)
        self.onApplyText = onApplyText
        self.onKeyboardHeightChange = onKeyboardHeightChange
        self.setupKeyboardListener()
    }

    func handleText() {
        onApplyText(input)
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
        switch filter.relationDetails.format {
        case .number: return .decimalPad
        case .url: return .URL
        case .email: return .emailAddress
        case .phone: return .phonePad
        default: return .default
        }
    }
    
    private static func initialValue(from filter: SetFilter) -> String {
        switch filter.conditionType {
        case .number:
            if let doubleValue = filter.filter.value.safeDoubleValue {
                return numberFormatter.string(from: NSNumber(floatLiteral: doubleValue)) ?? ""
            } else {
                return ""
            }
        case .text:
            return filter.filter.value.stringValue
        default: return ""
        }
    }
}
