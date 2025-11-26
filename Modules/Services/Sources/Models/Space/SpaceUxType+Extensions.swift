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
}

public extension Optional where Wrapped == SpaceUxType {
    var supportsMultiChats: Bool {
        self?.supportsMultiChats ?? true
    }
}

