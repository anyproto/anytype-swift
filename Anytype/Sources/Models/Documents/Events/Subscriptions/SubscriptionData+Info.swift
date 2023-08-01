import Services

extension SubscriptionData {
    var identifier: String {
        switch self {
        case .search(let description):
            return description.identifier
        case .objects(let description):
            return description.identifier
        }
    }
    
    var rowsPerPage: Int {
        switch self {
        case .search(let data):
            return data.limit
        case .objects:
            return UserDefaultsConfig.rowsPerPageInSet
        }
    }
}
