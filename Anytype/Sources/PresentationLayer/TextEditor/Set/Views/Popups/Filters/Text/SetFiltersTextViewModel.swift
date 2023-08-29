import SwiftUI
import Services

final class SetFiltersTextViewModel: ObservableObject {
    @Published var input = ""
    
    let keyboardType: UIKeyboardType
    let onApplyText: (String) -> Void
    
    private var keyboardListenerHelper: KeyboardEventsListnerHelper?
    
    private static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ""
        return formatter
    }()
    
    init(filter: SetFilter, onApplyText: @escaping (String) -> Void) {
        self.input = Self.initialValue(from: filter)
        self.keyboardType = Self.keybordType(for: filter)
        self.onApplyText = onApplyText
    }

    func handleText() {
        onApplyText(input)
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
