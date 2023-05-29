import SwiftProtobuf
import BlocksModels

protocol SetFiltersContentHandlerProtocol {
    func handleSelectedIds(_ ids: [String])
    func handleText(_ text: String)
    func handleCheckbox(_ isChecked: Bool)
    func handleDate(_ date: SetFiltersDate)
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
    
    func handleDate(_ date: SetFiltersDate) {
        let value = date.quickOption == .exactDate ?
        date.date.timeIntervalSince1970.protobufValue :
        date.numberOfDays.protobufValue
        
        let filter = filter.updated(
            filter: filter.filter.updated(
                condition: condition,
                value: value,
                quickOption: date.quickOption,
                format: filter.relationDetails.format
            )
        )
        onApply(filter)
    }
    
    func handleEmptyValue() {
        switch filter.conditionType {
        case .selected:
            handleSelectedIds([])
        case .number, .date:
            handleValue(0.protobufValue)
        case .text:
            handleValue("".protobufValue)
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
                value: value,
                format: filter.relationDetails.format
            )
        )
        onApply(filter)
    }
}
