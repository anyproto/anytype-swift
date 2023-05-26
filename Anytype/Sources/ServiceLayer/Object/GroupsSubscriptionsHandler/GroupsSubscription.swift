import Services

struct GroupsSubscription: Equatable {
    let identifier: SubscriptionId
    let relationKey: String
    let filters: [DataviewFilter]
    let source: [String]?
    let collectionId: String?
    
    init(
        identifier: SubscriptionId,
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
