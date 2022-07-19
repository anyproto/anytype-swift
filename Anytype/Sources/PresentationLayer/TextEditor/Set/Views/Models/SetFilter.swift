import BlocksModels
import SwiftProtobuf

struct SetFilter: Identifiable, Equatable, Hashable {
    let metadata: RelationMetadata
    let filter: DataviewFilter
    
    var id: String { metadata.id }
    
    var conditionString: String? {
        conditionType.data[filter.condition]
    }
    
    static func defaultCondition(for metadata: RelationMetadata) -> DataviewFilter.Condition {
        let conditionType =  Self.conditionType(for: metadata)
        switch conditionType {
        case .text, .number, .checkbox:
            return .equal
        case .selected:
            return .in
        }
    }
    
    var conditionType: Condition {
        Self.conditionType(for: metadata)
    }
    
    static func conditionType(for metadata: RelationMetadata) -> Condition {
        switch metadata.format {
        case .shortText, .longText, .url, .email, .file, .unrecognized, .phone:
            return .text
        case .number, .date:
            return .number
        case .tag, .status, .object:
            return .selected
        case .checkbox:
            return .checkbox
        }
    }
    
    enum Condition {
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
        
        static let textData: [DataviewFilter.Condition: String] = [
            .equal: Loc.EditSorts.Popup.Filter.Condition.Text.equal,
            .notEqual: Loc.EditSorts.Popup.Filter.Condition.Text.notEqual,
            .like: Loc.EditSorts.Popup.Filter.Condition.Text.like,
            .notLike: Loc.EditSorts.Popup.Filter.Condition.Text.notLike,
            .empty: Loc.EditSorts.Popup.Filter.Condition.General.empty,
            .notEmpty: Loc.EditSorts.Popup.Filter.Condition.General.notEmpty,
            .none: Loc.EditSorts.Popup.Filter.Condition.General.none
        ]
        
        static let numberData: [DataviewFilter.Condition: String] = [
            .equal: Loc.EditSorts.Popup.Filter.Condition.Number.equal,
            .notEqual: Loc.EditSorts.Popup.Filter.Condition.Number.notEqual,
            .greater: Loc.EditSorts.Popup.Filter.Condition.Number.greater,
            .less: Loc.EditSorts.Popup.Filter.Condition.Number.less,
            .greaterOrEqual: Loc.EditSorts.Popup.Filter.Condition.Number.greaterOrEqual,
            .lessOrEqual: Loc.EditSorts.Popup.Filter.Condition.Number.lessOrEqual,
            .empty: Loc.EditSorts.Popup.Filter.Condition.General.empty,
            .notEmpty: Loc.EditSorts.Popup.Filter.Condition.General.notEmpty,
            .none: Loc.EditSorts.Popup.Filter.Condition.General.none
        ]
        
        static let selectedData: [DataviewFilter.Condition: String] = [
            .in: Loc.EditSorts.Popup.Filter.Condition.Selected.in,
            .allIn: Loc.EditSorts.Popup.Filter.Condition.Selected.allIn,
            .equal: Loc.EditSorts.Popup.Filter.Condition.Selected.equal,
            .notIn: Loc.EditSorts.Popup.Filter.Condition.Selected.notIn,
            .empty: Loc.EditSorts.Popup.Filter.Condition.General.empty,
            .notEmpty: Loc.EditSorts.Popup.Filter.Condition.General.notEmpty,
            .none: Loc.EditSorts.Popup.Filter.Condition.General.none
        ]
        
        static let checkboxData: [DataviewFilter.Condition: String] = [
            .equal: Loc.EditSorts.Popup.Filter.Condition.Checkbox.equal,
            .notEqual: Loc.EditSorts.Popup.Filter.Condition.Checkbox.notEqual,
            .none: Loc.EditSorts.Popup.Filter.Condition.General.none
        ]
    }
}

extension SetFilter {
    func updated(
        metadata: RelationMetadata? = nil,
        filter: DataviewFilter? = nil
    ) -> SetFilter {
        SetFilter(
            metadata: metadata ?? self.metadata,
            filter: filter ?? self.filter
        )
    }
}

extension DataviewFilter {
    func updated(
        condition: DataviewFilter.Condition? = nil,
        value: SwiftProtobuf.Google_Protobuf_Value? = nil
    ) -> DataviewFilter {
        DataviewFilter(
            relationKey: self.relationKey,
            condition: condition ?? self.condition,
            value: value ?? self.value
        )
    }
}

extension DataviewFilter.Condition {
    var hasValues: Bool {
        switch self {
        case .none, .empty, .notEmpty:
            return false
        default:
            return true
        }
    }
}
