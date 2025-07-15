import Services

enum SpaceInfoScreenData: Hashable, Codable, Equatable, Identifiable {
    // Anytype widget screens
    case settings(spaceId: String)
    case typeLibrary(spaceId: String)
    case propertiesLibrary(spaceId: String)
    
    var id: Int {
        hashValue
    }
    
    var spaceId: String {
        switch self {
        case .settings(let spaceId):
            spaceId
        case .typeLibrary(let spaceId):
            spaceId
        case .propertiesLibrary(let spaceId):
            spaceId
        }
    }
}
