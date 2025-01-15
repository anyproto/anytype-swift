struct ObjectInfo: Hashable, Codable, Identifiable {
    let objectId: String
    let spaceId: String
    
    var id: String { objectId + spaceId }
}


enum AlertScreenData: Hashable, Codable {
    case spaceMember(ObjectInfo)
    
    var objectId: String {
        switch self {
        case .spaceMember(let info):
            info.objectId
        }
    }
    
    var spaceId: String {
        switch self {
        case .spaceMember(let info):
            info.spaceId
        }
    }
}
