import BlocksModels

extension DataviewFilter.Condition {
    var hasValues: Bool {
        switch self {
        case .none, .empty, .notEmpty:
            return false
        default:
            return true
        }
    }
    
    var stringValue: String {
        switch self {
        case .none: return "None"
        case .equal: return "Equal"
        case .notEqual: return "NotEqual"
        case .greater: return "Greater"
        case .less: return "Less"
        case .greaterOrEqual: return "GreaterOrEqual"
        case .lessOrEqual: return "LessOrEqual"
        case .like: return "Like"
        case .notLike: return "NotLike"
        case .in: return "In"
        case .notIn: return "NotIn"
        case .empty: return "Empty"
        case .notEmpty: return "NotEmpty"
        case .allIn: return "AllIn"
        case .notAllIn: return "NotAllIn"
        case .exactIn: return "ExactIn"
        case .notExactIn: return "NotExactIn"
        case .exists: return "Exists"
        case .UNRECOGNIZED(let value): return "UNRECOGNIZED \(value)"
        }
    }
}
