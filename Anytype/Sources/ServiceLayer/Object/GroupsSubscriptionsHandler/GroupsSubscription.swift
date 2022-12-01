import BlocksModels

struct GroupsSubscription: Equatable {
    let identifier: SubscriptionId
    let relationKey: String
    let filters: [DataviewFilter]
    let source: [String]
    
    init(
        identifier: SubscriptionId,
        relationKey: String,
        filters: [DataviewFilter],
        source: [String]
    ) {
        self.identifier = identifier
        self.relationKey = relationKey
        self.filters = filters
        self.source = source
    }
}
