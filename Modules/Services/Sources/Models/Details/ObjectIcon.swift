import AnytypeCore

public enum ObjectIcon: Hashable {
    case basic(_ imageObjectId: String)
    case profile(Profile)
    case emoji(Emoji)
    case bookmark(_ imageId: String)
    case space(Space)
    case todo(Bool)
    case placeholder(Character?)
    case file(mimeType: String, name: String)
    case deleted
}

// MARK: - ProfileIcon

public extension ObjectIcon {
    
    enum Profile: Hashable {
        case imageId(String)
        case name(String)
    }
    
}

public extension ObjectIcon {
    enum Space: Hashable {
        case name(String)
        case gradient(GradientId)
    }
}
