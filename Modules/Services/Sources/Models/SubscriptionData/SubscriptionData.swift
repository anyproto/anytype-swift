public enum SubscriptionData: Equatable, Sendable {
    case search(Search)
    case objects(Object)
    case crossSpaceSearch(CrossSpaceSearch)
}

extension SubscriptionData {

    public struct Search: Equatable, Sendable {
        public let identifier: String
        public let spaceId: String
        public let sorts: [DataviewSort]
        public let filters: [DataviewFilter]
        public let limit: Int
        public let offset: Int
        public let keys: [String]
        public let afterID: String?
        public let beforeID: String?
        public let source: [String]?
        public let noDepSubscription: Bool
        public let collectionId: String?

        public init(
            identifier: String,
            spaceId: String,
            sorts: [DataviewSort] = [],
            filters: [DataviewFilter],
            limit: Int,
            offset: Int = 0,
            keys: [String],
            afterID: String? = nil,
            beforeID: String? = nil,
            source: [String]? = nil,
            noDepSubscription: Bool = false,
            collectionId: String? = nil
        ) {
            self.identifier = identifier
            self.spaceId = spaceId
            self.sorts = sorts
            self.filters = filters
            self.limit = limit
            self.offset = offset
            self.keys = keys
            self.afterID = afterID
            self.beforeID = beforeID
            self.source = source
            self.noDepSubscription = noDepSubscription
            self.collectionId = collectionId
        }
    }

    public struct Object: Equatable, Sendable {

        public let identifier: String
        public let spaceId: String
        public let objectIds: [String]
        public let keys: [String]
        public let ignoreWorkspace: String?

        public init(
            identifier: String,
            spaceId: String,
            objectIds: [String],
            keys: [String],
            ignoreWorkspace: String? = nil
        ) {
            self.identifier = identifier
            self.spaceId = spaceId
            self.objectIds = objectIds
            self.keys = keys
            self.ignoreWorkspace = ignoreWorkspace
        }
    }
    
    public struct CrossSpaceSearch: Equatable, Sendable {
        public let identifier: String
        public let sorts: [DataviewSort]
        public let filters: [DataviewFilter]
        public let keys: [String]
        public let source: [String]?
        public let noDepSubscription: Bool
        public let collectionId: String?

        public init(
            identifier: String,
            sorts: [DataviewSort] = [],
            filters: [DataviewFilter],
            keys: [String],
            source: [String]? = nil,
            noDepSubscription: Bool = false,
            collectionId: String? = nil
        ) {
            self.identifier = identifier
            self.sorts = sorts
            self.filters = filters
            self.keys = keys
            self.source = source
            self.noDepSubscription = noDepSubscription
            self.collectionId = collectionId
        }
    }
}
