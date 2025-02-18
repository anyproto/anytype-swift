import Services

enum SettingsScreenData: Hashable, Codable, Equatable, Identifiable {
    // Anytype widget screens
    case mainScreen(info: AccountInfo)
    case spaceDetails(info: AccountInfo)
    case typeLibrary(spaceId: String)
    
    var id: Int {
        hashValue
    }
    
    var spaceId: String {
        switch self {
        case .mainScreen(let info):
            info.accountSpaceId
        case .spaceDetails(let info):
            info.accountSpaceId
        case .typeLibrary(let spaceId):
            spaceId
        }
    }
}
