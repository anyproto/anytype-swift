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
}
