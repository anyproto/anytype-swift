import AnytypeCore

public enum ObjectIcon: Hashable, Sendable, Equatable {
    case basic(_ imageId: String)
    case profile(Profile)
    case emoji(Emoji)
    case customIcon(CustomIcon, CustomIconColor)
    case bookmark(_ imageId: String)
    case space(Space)
    case todo(_ checked: Bool, _ objectId: String?)
    case placeholder(_ name: String)
    case file(mimeType: String, name: String)
    case deleted
    case empty(EmptyType)
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
        case .todo, .emoji, .placeholder, .file, .deleted, .empty, .customIcon:
            return nil
        }
    }
}

// MARK: - ProfileIcon

public extension ObjectIcon {
    
    enum Profile: Hashable, Sendable {
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
    enum Space: Hashable, Sendable {
        case name(name: String, iconOption: Int)
        case imageId(_ imageId: String)
        
        var imageId: String? {
            switch self {
            case .imageId(let imageId):
                return imageId
            case .name(_, _):
                return nil
            }
        }
    }
}

public extension ObjectIcon {
    enum EmptyType: Hashable, Sendable {
        case page
        case list
        case bookmark
        case chat
        case objectType
        case tag
        case date
    }
}
