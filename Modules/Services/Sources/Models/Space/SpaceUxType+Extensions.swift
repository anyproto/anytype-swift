import ProtobufMessages

public extension SpaceUxType {
    var isStream: Bool {
        self == .stream
    }

    var isChat: Bool {
        self == .chat
    }

    var isData: Bool {
        self == .data
    }

    var isOneToOne: Bool {
        self == .oneToOne
    }

    var supportsMultiChats: Bool {
        switch self {
        case .chat, .stream, .none, .oneToOne, .UNRECOGNIZED:
            return false
        case .data:
            return true
        }
    }

    var initialScreenIsChat: Bool {
        switch self {
        case .chat, .stream, .oneToOne:
            return true
        case .data, .none, .UNRECOGNIZED:
            return false
        }
    }

    var supportsMentions: Bool {
        switch self {
        case .chat, .stream, .data, .none, .UNRECOGNIZED:
            return true
        case .oneToOne:
            return false
        }
    }

    var showsMessageAuthor: Bool {
        switch self {
        case .chat, .data, .none, .UNRECOGNIZED:
            return true
        case .stream, .oneToOne:
            return false
        }
    }

    var positionsYourMessageOnRight: Bool {
        switch self {
        case .chat, .data, .oneToOne, .none, .UNRECOGNIZED:
            return true
        case .stream:
            return false
        }
    }

    var supportsJoinSpaceButton: Bool {
        switch self {
        case .chat, .stream, .data, .none, .UNRECOGNIZED:
            return true
        case .oneToOne:
            return false
        }
    }
}

public extension Optional where Wrapped == SpaceUxType {
    var supportsMultiChats: Bool {
        self?.supportsMultiChats ?? true
    }
}

