import BlocksModels

struct SetFilter: Identifiable, Equatable, Hashable {
    let metadata: RelationMetadata
    let filter: DataviewFilter
    
    var id: String { metadata.id }
    
    var conditionString: String? {
        conditionType.data[filter.condition]
    }
    
    private var conditionType: Condition {
        switch metadata.format {
        case .shortText, .longText, .url, .email, .file, .unrecognized:
            return .text
        case .number, .date, .phone:
            return .number
        case .tag, .status, .object:
            return .selected
        case .checkbox:
            return .checkbox
        }
    }
    
    private enum Condition {
        case text
        case number
        case selected
        case checkbox
        
        var data: [DataviewFilter.Condition: String] {
            switch self {
            case .text:
                return Self.textData
            case .number:
                return Self.numberData
            case .selected:
                return Self.selectedData
            case .checkbox:
                return Self.checkboxData
            }
        }
        
        private static let textData: [DataviewFilter.Condition: String] = [
            .equal: "EditSorts.Popup.Filter.Condition.Text.Equal".localized,
            .notEqual: "EditSorts.Popup.Filter.Condition.Text.NotEqual".localized,
            .like: "EditSorts.Popup.Filter.Condition.Text.Like".localized,
            .notLike: "EditSorts.Popup.Filter.Condition.Text.NotLike".localized,
            .empty: "EditSorts.Popup.Filter.Condition.General.Empty".localized,
            .notEmpty: "EditSorts.Popup.Filter.Condition.General.NotEmpty".localized,
            .none: "EditSorts.Popup.Filter.Condition.General.None".localized
        ]
        
        private static let numberData: [DataviewFilter.Condition: String] = [
            .equal: "EditSorts.Popup.Filter.Condition.Number.Equal".localized,
            .notEqual: "EditSorts.Popup.Filter.Condition.Number.NotEqual".localized,
            .greater: "EditSorts.Popup.Filter.Condition.Number.Greater".localized,
            .less: "EditSorts.Popup.Filter.Condition.Number.Less".localized,
            .greaterOrEqual: "EditSorts.Popup.Filter.Condition.Number.GreaterOrEqual".localized,
            .lessOrEqual: "EditSorts.Popup.Filter.Condition.Number.LessOrEqual".localized,
            .empty: "EditSorts.Popup.Filter.Condition.General.Empty".localized,
            .notEmpty: "EditSorts.Popup.Filter.Condition.General.NotEmpty".localized,
            .none: "EditSorts.Popup.Filter.Condition.General.None".localized
        ]
        
        private static let selectedData: [DataviewFilter.Condition: String] = [
            .in: "EditSorts.Popup.Filter.Condition.Selected.In".localized,
            .allIn: "EditSorts.Popup.Filter.Condition.Selected.AllIn".localized,
            .equal: "EditSorts.Popup.Filter.Condition.Selected.Equal".localized,
            .notIn: "EditSorts.Popup.Filter.Condition.Selected.NotIn".localized,
            .empty: "EditSorts.Popup.Filter.Condition.General.Empty".localized,
            .notEmpty: "EditSorts.Popup.Filter.Condition.General.NotEmpty".localized,
            .none: "EditSorts.Popup.Filter.Condition.General.None".localized
        ]
        
        private static let checkboxData: [DataviewFilter.Condition: String] = [
            .equal: "EditSorts.Popup.Filter.Condition.Checkbox.Equal".localized,
            .notEqual: "EditSorts.Popup.Filter.Condition.Checkbox.NotEqual".localized,
            .none: "EditSorts.Popup.Filter.Condition.General.None".localized
        ]
    }
}
