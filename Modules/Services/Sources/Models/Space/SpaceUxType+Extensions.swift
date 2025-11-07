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

    var showsChatLayouts: Bool {
        switch self {
        case .chat, .stream, .none, .UNRECOGNIZED:
            return false
        case .data:
            return true
        }
    }
}

public extension Optional where Wrapped == SpaceUxType {
    var showsChatLayouts: Bool {
        self?.showsChatLayouts ?? true
    }
}

