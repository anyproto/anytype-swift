import Services

enum SpaceInfoScreenData: Hashable, Codable, Equatable, Identifiable {
    // Anytype widget screens
    case mainScreen(info: AccountInfo)
    case typeLibrary(spaceId: String)
    
    var id: Int {
        hashValue
    }
    
    var spaceId: String {
        switch self {
        case .mainScreen(let info):
            info.accountSpaceId
        case .typeLibrary(let spaceId):
            spaceId
        }
    }
}
