
enum AlertScreenData: Hashable, Codable {
    case spaceMember(objectId: String, spaceId: String)
    
    var objectId: String {
        switch self {
        case .spaceMember(let objectId, _):
            objectId
        }
    }
    
    var spaceId: String {
        switch self {
        case .spaceMember(_, let spaceId):
            spaceId
        }
    }
}
