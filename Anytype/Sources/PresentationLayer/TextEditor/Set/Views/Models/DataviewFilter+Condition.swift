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
}
