import AnytypeCore

public enum ObjectIcon: Hashable, Sendable {
    case basic(_ imageId: String)
    case profile(Profile)
    case emoji(Emoji)
    case bookmark(_ imageId: String)
    case space(Space)
    case todo(_ checked: Bool, _ objectId: String?)
    case placeholder(_ name: String)
    case file(mimeType: String, name: String)
    case deleted
}

// MARK: - ProfileIcon

public extension ObjectIcon {
    
    enum Profile: Hashable, Sendable {
        case imageId(String)
        case name(String)
    }
    
}

public extension ObjectIcon {
    enum Space: Hashable, Sendable {
        case name(String)
        case gradient(GradientId)
        case imageId(_ imageId: String)
    }
}
