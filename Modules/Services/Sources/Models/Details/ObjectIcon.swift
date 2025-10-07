import AnytypeCore

public enum ObjectIcon: Hashable, Sendable, Equatable, Codable {
    case basic(_ imageId: String)
    case profile(Profile)
    case emoji(Emoji)
    case customIcon(CustomIconData)
    case bookmark(_ imageId: String)
    case space(Space)
    case todo(_ checked: Bool, _ objectId: String?)
    case placeholder(_ name: String)
    case file(mimeType: String, name: String)
    case deleted
}

public extension ObjectIcon {
    var imageId: String? {
        switch self {
        case .basic(let imageId):
            return imageId
        case .profile(let data):
            return data.imageId
        case .bookmark(let imageId):
            return imageId
        case .space(let data):
            return data.imageId
        case .todo, .emoji, .placeholder, .file, .deleted, .customIcon:
            return nil
        }
    }
    
    var customIcon: CustomIcon? {
        switch self {
        case .customIcon(let data):
            return data.icon
        default:
            return nil
        }
    }
}

// MARK: - ProfileIcon

public extension ObjectIcon {
    
    enum Profile: Hashable, Sendable, Codable {
        case imageId(String)
        case name(String)
        case placeholder
        
        var imageId: String? {
            switch self {
            case .imageId(let imageId):
                return imageId
            case .name(_):
                return nil
            case .placeholder:
                return nil
            }
        }
    }
    
}

public extension ObjectIcon {
    enum Space: Hashable, Sendable, Codable {
        case name(name: String, iconOption: Int, circular: Bool)
        case imageId(_ imageId: String, name: String, iconOption: Int, circular: Bool)
        case localPath(_ path: String, circular: Bool)
        
        var imageId: String? {
            switch self {
            case .imageId(let imageId, _, _, _):
                return imageId
            case .name, .localPath:
                return nil
            }
        }
    }
}

