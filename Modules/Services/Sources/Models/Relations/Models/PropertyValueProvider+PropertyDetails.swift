import Foundation

public extension PropertyValueProvider {
    
    /// Use this method only for cases where relation can contains single value or array.
    /// In other cases use concreate API.
    func stringValueOrArray(for relationDetails: RelationDetails) -> [String] {
        if relationDetails.isMultiSelect {
            return stringArrayValue(for: relationDetails.key)
        } else {
            return [stringValue(for: relationDetails.key)]
        }
    }
}
