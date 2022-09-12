import BlocksModels
import SwiftProtobuf
import OrderedCollections

struct SetFilter: Identifiable, Equatable, Hashable {
    let relation: Relation
    let filter: DataviewFilter
    
    var id: String { relation.id }
    
    var conditionString: String? {
        conditionType.data[filter.condition]
    }
    
    static func defaultCondition(for relation: Relation) -> DataviewFilter.Condition {
        let conditionType =  Self.conditionType(for: relation)
        switch conditionType {
        case .text, .number, .checkbox, .date:
            return .equal
        case .selected:
            return .in
        }
    }
    
    var conditionType: Condition {
        Self.conditionType(for: relation)
    }
    
    static func conditionType(for relation: Relation) -> Condition {
        switch relation.format {
        case .shortText, .longText, .url, .email, .file, .unrecognized, .phone:
            return .text
        case .number:
            return .number
        case .tag, .status, .object:
            return .selected(relation.format)
        case .checkbox:
            return .checkbox
        case .date:
            return .date
        }
    }
    
    enum Condition {
        case text
        case number
        case selected(RelationFormat)
        case checkbox
        case date
        
        var data: OrderedDictionary<DataviewFilter.Condition, String> {
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
        
        static let textData: OrderedDictionary<DataviewFilter.Condition, String> = [
            .none: Loc.EditSet.Popup.Filter.Condition.General.none,
            .equal: Loc.EditSet.Popup.Filter.Condition.Text.equal,
            .notEqual: Loc.EditSet.Popup.Filter.Condition.Text.notEqual,
            .like: Loc.EditSet.Popup.Filter.Condition.Text.like,
            .notLike: Loc.EditSet.Popup.Filter.Condition.Text.notLike,
            .empty: Loc.EditSet.Popup.Filter.Condition.General.empty,
            .notEmpty: Loc.EditSet.Popup.Filter.Condition.General.notEmpty
        ]
        
        static let numberData: OrderedDictionary<DataviewFilter.Condition, String> = [
            .none: Loc.EditSet.Popup.Filter.Condition.General.none,
            .equal: Loc.EditSet.Popup.Filter.Condition.Number.equal,
            .notEqual: Loc.EditSet.Popup.Filter.Condition.Number.notEqual,
            .greater: Loc.EditSet.Popup.Filter.Condition.Number.greater,
            .less: Loc.EditSet.Popup.Filter.Condition.Number.less,
            .greaterOrEqual: Loc.EditSet.Popup.Filter.Condition.Number.greaterOrEqual,
            .lessOrEqual: Loc.EditSet.Popup.Filter.Condition.Number.lessOrEqual,
            .empty: Loc.EditSet.Popup.Filter.Condition.General.empty,
            .notEmpty: Loc.EditSet.Popup.Filter.Condition.General.notEmpty
        ]
        
        static let selectedData: OrderedDictionary<DataviewFilter.Condition, String> = [
            .none: Loc.EditSet.Popup.Filter.Condition.General.none,
            .in: Loc.EditSet.Popup.Filter.Condition.Selected.in,
            .allIn: Loc.EditSet.Popup.Filter.Condition.Selected.allIn,
            .equal: Loc.EditSet.Popup.Filter.Condition.Selected.equal,
            .notIn: Loc.EditSet.Popup.Filter.Condition.Selected.notIn,
            .empty: Loc.EditSet.Popup.Filter.Condition.General.empty,
            .notEmpty: Loc.EditSet.Popup.Filter.Condition.General.notEmpty
        ]
        
        static let checkboxData: OrderedDictionary<DataviewFilter.Condition, String> = [
            .none: Loc.EditSet.Popup.Filter.Condition.General.none,
            .equal: Loc.EditSet.Popup.Filter.Condition.Checkbox.equal,
            .notEqual: Loc.EditSet.Popup.Filter.Condition.Checkbox.notEqual,
        ]
        
        static let dateData: OrderedDictionary<DataviewFilter.Condition, String> = [
            .none: Loc.EditSet.Popup.Filter.Condition.General.none,
            .equal: Loc.EditSet.Popup.Filter.Condition.Date.equal,
            .greater: Loc.EditSet.Popup.Filter.Condition.Date.after,
            .less: Loc.EditSet.Popup.Filter.Condition.Date.before,
            .greaterOrEqual: Loc.EditSet.Popup.Filter.Condition.Date.onOrAfter,
            .lessOrEqual: Loc.EditSet.Popup.Filter.Condition.Date.onOrBefore,
            .in: Loc.EditSet.Popup.Filter.Condition.Date.in,
            .empty: Loc.EditSet.Popup.Filter.Condition.General.empty,
            .notEmpty: Loc.EditSet.Popup.Filter.Condition.General.notEmpty
        ]
    }
}

extension SetFilter {
    func updated(
        relation: Relation? = nil,
        filter: DataviewFilter? = nil
    ) -> SetFilter {
        SetFilter(
            relation: relation ?? self.relation,
            filter: filter ?? self.filter
        )
    }
}
