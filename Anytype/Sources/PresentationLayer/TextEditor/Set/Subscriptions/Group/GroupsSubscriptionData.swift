import Services

struct GroupsSubscriptionData: Equatable {
    let identifier: String
    let relationKey: String
    let filters: [DataviewFilter]
    let source: [String]?
    let collectionId: String?
    
    init(
        identifier: String,
        relationKey: String,
        filters: [DataviewFilter],
        source: [String]?,
        collectionId: String?
    ) {
        self.identifier = identifier
        self.relationKey = relationKey
        self.filters = filters
        self.source = source
        self.collectionId = collectionId
    }
}
