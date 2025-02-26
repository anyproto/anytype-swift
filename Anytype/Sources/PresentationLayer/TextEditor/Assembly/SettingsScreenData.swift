import Services

enum SpaceInfoScreenData: Hashable, Codable, Equatable, Identifiable {
    // Anytype widget screens
    case mainScreen(info: AccountInfo)
    
    var id: Int {
        hashValue
    }
    
    var spaceId: String {
        switch self {
        case .mainScreen(let info):
            info.accountSpaceId
        }
    }
    
    var accountInfo: AccountInfo {
        switch self {
        case .mainScreen(let info):
            info
        }
    }
}
