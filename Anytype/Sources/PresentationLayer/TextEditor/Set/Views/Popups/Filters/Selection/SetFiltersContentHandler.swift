import SwiftProtobuf
import BlocksModels

protocol SetFiltersContentHandlerProtocol {
    func handleSelectedIds(_ ids: [String])
    func handleText(_ text: String)
    func handleCheckbox(_ isChecked: Bool)
    func handleEmptyValue()
    func updateCondition(_ condition: DataviewFilter.Condition)
}

final class SetFiltersContentHandler: SetFiltersContentHandlerProtocol {
    private var condition: DataviewFilter.Condition
    private let filter: SetFilter
    private let onApply: (SetFilter) -> Void
    
    init(filter: SetFilter, onApply: @escaping (SetFilter) -> Void) {
        self.condition = filter.filter.condition
        self.filter = filter
        self.onApply = onApply
    }
    
    func handleSelectedIds(_ ids: [String]) {
        handleValue(ids.protobufValue)
    }
    
    func handleText(_ text: String) {
        switch filter.conditionType {
        case .number:
            if let double = Double(text) {
                handleValue(double.protobufValue)
            }
        default:
            handleValue(text.protobufValue)
        }
    }
    
    func handleCheckbox(_ isChecked: Bool) {
        handleValue(isChecked.protobufValue)
    }
    
    func handleEmptyValue() {
        switch filter.conditionType {
        case .selected:
            handleSelectedIds([])
        case .number:
            handleText("0")
        case .text:
            handleText("")
        case .checkbox:
            handleCheckbox(false)
        }
    }
    
    func updateCondition(_ condition: DataviewFilter.Condition) {
        self.condition = condition
    }
    
    private func handleValue(_ value: SwiftProtobuf.Google_Protobuf_Value) {
        let filter = filter.updated(
            filter: filter.filter.updated(
                condition: condition,
                value: value
            )
        )
        onApply(filter)
    }
}
