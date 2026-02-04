import SwiftUI
import Services

@MainActor
@Observable
final class SetFiltersTextViewModel {
    var input = ""

    @ObservationIgnored
    let keyboardType: UIKeyboardType
    @ObservationIgnored
    let onApplyText: (String) -> Void

    @ObservationIgnored
    private var keyboardListenerHelper: KeyboardEventsListnerHelper?
    
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
                return NumberFormatter.decimalWithNoSeparator.string(from: NSNumber(floatLiteral: doubleValue)) ?? ""
            } else {
                return ""
            }
        case .text:
            return filter.filter.value.stringValue
        default: return ""
        }
    }
}
