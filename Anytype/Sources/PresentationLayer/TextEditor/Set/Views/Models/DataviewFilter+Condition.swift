import Services
import SwiftProtobuf

extension DataviewFilter {
    var isSupportedForSubscription: Bool {
        // Conditions that don't require values (.none, .empty, .notEmpty) are always valid
        guard condition.hasValues else { return true }

        // Date filters with relative quick options (today, yesterday, etc.) don't require
        // an explicit value — middleware resolves the date from quickOption at query time
        if format == .date && quickOption != .exactDate {
            return true
        }

        // No value set at all
        guard hasValue else { return false }

        switch value.kind {
        case .listValue(let list) where list.values.isEmpty:
            return false
        case .stringValue(let str) where str.isEmpty:
            return false
        case .nullValue:
            return false
        case .numberValue(let num) where num == 0 && format == .date && quickOption == .exactDate:
            return false
        default:
            return true
        }
    }
}

extension Array where Element == DataviewFilter {
    func enrichingFormats(with relationsDetails: [PropertyDetails]) -> [DataviewFilter] {
        map { filter in
            var enriched = filter
            if !filter.relationKey.isEmpty,
               let details = relationsDetails.first(where: { $0.key == filter.relationKey }) {
                enriched.format = details.format.asMiddleware
            }
            if filter.operator != .no {
                enriched.nestedFilters = filter.nestedFilters.enrichingFormats(with: relationsDetails)
            }
            return enriched
        }
    }

    func removingUnsupportedFilters() -> [DataviewFilter] {
        compactMap { filter in
            // Advanced filter: recursively clean nested filters
            if filter.operator != .no {
                var cleaned = filter
                cleaned.nestedFilters = filter.nestedFilters.removingUnsupportedFilters()
                return cleaned.nestedFilters.isEmpty ? nil : cleaned
            }
            return filter.isSupportedForSubscription ? filter : nil
        }
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
