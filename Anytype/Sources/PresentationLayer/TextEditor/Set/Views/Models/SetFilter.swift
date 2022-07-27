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
        case .text, .number, .checkbox, .date:
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
        case .number:
            return .number
        case .tag, .status, .object:
            return .selected(metadata.format)
        case .checkbox:
            return .checkbox
        case .date:
            return .date
        }
    }
    
    enum Condition {
        case text
        case number
        case selected(RelationMetadata.Format)
        case checkbox
        case date
        
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
            case .date:
                return Self.dateData
            }
        }
        
        static let textData: [DataviewFilter.Condition: String] = [
            .equal: Loc.EditSet.Popup.Filter.Condition.Text.equal,
            .notEqual: Loc.EditSet.Popup.Filter.Condition.Text.notEqual,
            .like: Loc.EditSet.Popup.Filter.Condition.Text.like,
            .notLike: Loc.EditSet.Popup.Filter.Condition.Text.notLike,
            .empty: Loc.EditSet.Popup.Filter.Condition.General.empty,
            .notEmpty: Loc.EditSet.Popup.Filter.Condition.General.notEmpty,
            .none: Loc.EditSet.Popup.Filter.Condition.General.none
        ]
        
        static let numberData: [DataviewFilter.Condition: String] = [
            .equal: Loc.EditSet.Popup.Filter.Condition.Number.equal,
            .notEqual: Loc.EditSet.Popup.Filter.Condition.Number.notEqual,
            .greater: Loc.EditSet.Popup.Filter.Condition.Number.greater,
            .less: Loc.EditSet.Popup.Filter.Condition.Number.less,
            .greaterOrEqual: Loc.EditSet.Popup.Filter.Condition.Number.greaterOrEqual,
            .lessOrEqual: Loc.EditSet.Popup.Filter.Condition.Number.lessOrEqual,
            .empty: Loc.EditSet.Popup.Filter.Condition.General.empty,
            .notEmpty: Loc.EditSet.Popup.Filter.Condition.General.notEmpty,
            .none: Loc.EditSet.Popup.Filter.Condition.General.none
        ]
        
        static let selectedData: [DataviewFilter.Condition: String] = [
            .in: Loc.EditSet.Popup.Filter.Condition.Selected.in,
            .allIn: Loc.EditSet.Popup.Filter.Condition.Selected.allIn,
            .equal: Loc.EditSet.Popup.Filter.Condition.Selected.equal,
            .notIn: Loc.EditSet.Popup.Filter.Condition.Selected.notIn,
            .empty: Loc.EditSet.Popup.Filter.Condition.General.empty,
            .notEmpty: Loc.EditSet.Popup.Filter.Condition.General.notEmpty,
            .none: Loc.EditSet.Popup.Filter.Condition.General.none
        ]
        
        static let checkboxData: [DataviewFilter.Condition: String] = [
            .equal: Loc.EditSet.Popup.Filter.Condition.Checkbox.equal,
            .notEqual: Loc.EditSet.Popup.Filter.Condition.Checkbox.notEqual,
            .none: Loc.EditSet.Popup.Filter.Condition.General.none
        ]
        
        static let dateData: [DataviewFilter.Condition: String] = [
            .equal: Loc.EditSet.Popup.Filter.Condition.Date.equal,
            .greater: Loc.EditSet.Popup.Filter.Condition.Date.after,
            .less: Loc.EditSet.Popup.Filter.Condition.Date.before,
            .greaterOrEqual: Loc.EditSet.Popup.Filter.Condition.Date.onOrAfter,
            .lessOrEqual: Loc.EditSet.Popup.Filter.Condition.Date.onOrBefore,
            .in: Loc.EditSet.Popup.Filter.Condition.Date.in,
            .empty: Loc.EditSet.Popup.Filter.Condition.General.empty,
            .notEmpty: Loc.EditSet.Popup.Filter.Condition.General.notEmpty,
            .none: Loc.EditSet.Popup.Filter.Condition.General.none
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
        value: SwiftProtobuf.Google_Protobuf_Value? = nil,
        quickOption: DataviewFilter.QuickOption? = nil
    ) -> DataviewFilter {
        DataviewFilter(
            relationKey: self.relationKey,
            condition: condition ?? self.condition,
            value: value ?? self.value,
            quickOption: quickOption ?? self.quickOption
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

extension DataviewFilter.QuickOption {
    var title: String {
        switch self {
        case .yesterday:
            return Loc.EditSet.Popup.Filter.Date.Option.yesterday
        case .today:
            return Loc.EditSet.Popup.Filter.Date.Option.today
        case .tomorrow:
            return Loc.EditSet.Popup.Filter.Date.Option.tomorrow
        case .lastWeek:
            return Loc.EditSet.Popup.Filter.Date.Option.lastWeek
        case .currentWeek:
            return Loc.EditSet.Popup.Filter.Date.Option.currentWeek
        case .nextWeek:
            return Loc.EditSet.Popup.Filter.Date.Option.nextWeek
        case .lastMonth:
            return Loc.EditSet.Popup.Filter.Date.Option.lastMonth
        case .currentMonth:
            return Loc.EditSet.Popup.Filter.Date.Option.currentMonth
        case .nextMonth:
            return Loc.EditSet.Popup.Filter.Date.Option.nextMonth
        case .numberOfDaysAgo:
            return Loc.EditSet.Popup.Filter.Date.Option.numberOfDaysAgo
        case .numberOfDaysNow:
            return Loc.EditSet.Popup.Filter.Date.Option.numberOfDaysFromNow
        case .exactDate:
            return Loc.EditSet.Popup.Filter.Date.Option.exactDate
        case .UNRECOGNIZED(_):
            return ""
        }
    }
}
