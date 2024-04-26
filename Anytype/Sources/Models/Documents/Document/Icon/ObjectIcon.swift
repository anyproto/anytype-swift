import AnytypeCore
import Services

enum ObjectIcon: Hashable {
    case basic(_ imageObjectId: String)
    case profile(Profile)
    case emoji(Emoji)
    case bookmark(_ imageId: String)
    case space(Space)
    case todo(Bool)
    case placeholder(Character?)
}

// MARK: - ProfileIcon

extension ObjectIcon {
    
    enum Profile: Hashable {
        case imageId(String)
        case character(Character)
    }
    
}

extension ObjectIcon {
    enum Space: Hashable {
        case character(Character)
        case gradient(GradientId)
    }
}
