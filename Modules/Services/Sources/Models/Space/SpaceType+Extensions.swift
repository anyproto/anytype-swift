import ProtobufMessages

public extension SpaceType {

    var supportsMultiChats: Bool {
        switch self {
        case .regular:
            return true
        case .chat, .oneToOne, .tech, .unknown, .UNRECOGNIZED:
            return false
        }
    }

    var initialScreenIsChat: Bool {
        switch self {
        case .chat, .oneToOne:
            return true
        case .regular, .tech, .unknown, .UNRECOGNIZED:
            return false
        }
    }

    var supportsMentions: Bool {
        switch self {
        case .chat, .regular, .tech, .unknown, .UNRECOGNIZED:
            return true
        case .oneToOne:
            return false
        }
    }

    var showsMessageAuthor: Bool {
        switch self {
        case .chat, .regular, .tech, .unknown, .UNRECOGNIZED:
            return true
        case .oneToOne:
            return false
        }
    }

    var supportsJoinSpaceButton: Bool {
        switch self {
        case .chat, .regular, .tech, .unknown, .UNRECOGNIZED:
            return true
        case .oneToOne:
            return false
        }
    }
}

public extension Optional where Wrapped == SpaceType {
    var supportsMultiChats: Bool {
        self?.supportsMultiChats ?? true
    }
}
