import Foundation
import BlocksModels

enum SubscriptionData {
    
    case search(Search)
    case objects(Object)
    
    var identifier: SubscriptionId {
        switch self {
        case .search(let description):
            return description.identifier
        case .objects(let description):
            return description.identifier
        }
    }
    
    var limit: Int {
        switch self {
        case .search(let data):
            return data.limit
        case .objects:
            return UserDefaultsConfig.rowsPerPageInSet
        }
    }
}

extension SubscriptionData {
    
    struct Search: Equatable {
        let identifier: SubscriptionId
        let sorts: [DataviewSort]
        let filters: [DataviewFilter]
        let limit: Int
        let offset: Int
        let keys: [String]
        let afterID: String?
        let beforeID: String?
        let source: [String]
        let ignoreWorkspace: String?
        let noDepSubscription: Bool
        
        init(
            identifier: SubscriptionId,
            sorts: [DataviewSort],
            filters: [DataviewFilter],
            limit: Int,
            offset: Int,
            keys: [String],
            afterID: String? = nil,
            beforeID: String? = nil,
            source: [String] = [],
            ignoreWorkspace: String? = nil,
            noDepSubscription: Bool = false
        ) {
            self.identifier = identifier
            self.sorts = sorts
            self.filters = filters
            self.limit = limit
            self.offset = offset
            self.keys = keys
            self.afterID = afterID
            self.beforeID = beforeID
            self.source = source
            self.ignoreWorkspace = ignoreWorkspace
            self.noDepSubscription = noDepSubscription
        }
    }

    struct Object: Equatable {
        
        let identifier: SubscriptionId
        let objectIds: [String]
        let keys: [String]
        let ignoreWorkspace: String?
        
        init(
            identifier: SubscriptionId,
            objectIds: [String],
            keys: [String],
            ignoreWorkspace: String? = nil
        ) {
            self.identifier = identifier
            self.objectIds = objectIds
            self.keys = keys
            self.ignoreWorkspace = ignoreWorkspace
        }
    }
}

extension SubscriptionData: Equatable {
    static func == (lhs: SubscriptionData, rhs: SubscriptionData) -> Bool {
        switch (lhs, rhs) {
        case let (.search(lhsSearch), .search(rhsSearch)):
            return lhsSearch == rhsSearch
        case let (.objects(lhsObject), .objects(rhsObject)):
            return lhsObject == rhsObject
        default:
            return false
        }
    }
}
