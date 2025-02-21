import Services

enum SettingsScreenData: Hashable, Codable, Equatable, Identifiable {
    // Anytype widget screens
    case mainScreen(info: AccountInfo)
    
    var id: Int {
        hashValue
    }
    
    var spaceId: String {
        switch self {
        case .mainScreen(let info):
            return info.accountSpaceId
        }
    }
}
