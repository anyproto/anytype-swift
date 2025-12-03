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
        case .chat, .stream, .data:
            return true
        case .oneToOne, .none, .UNRECOGNIZED:
            return false
        }
    }

    var showsMessageAuthor: Bool {
        switch self {
        case .chat, .stream, .data:
            return true
        case .oneToOne, .none, .UNRECOGNIZED:
            return false
        }
    }
}

public extension Optional where Wrapped == SpaceUxType {
    var supportsMultiChats: Bool {
        self?.supportsMultiChats ?? true
    }
}

