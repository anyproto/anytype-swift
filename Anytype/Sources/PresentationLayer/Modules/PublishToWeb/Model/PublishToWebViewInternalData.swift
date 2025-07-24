import Services


enum DomainType: Equatable, Hashable {
    case paid(String)
    case free(String)
}

struct PublishToWebViewInternalData: Identifiable, Hashable {
    let objectId: String
    let spaceId: String
    let domain: DomainType
    let status: PublishState?
    let objectDetails: ObjectDetails
    let spaceName: String
    
    var id: String { objectId + spaceId }
}
