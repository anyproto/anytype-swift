import Services

enum ConversationType {
    case chat
    case stream
    
    var isChat: Bool {
        self == .chat
    }
}

extension SpaceUxType {
    var asConversationType: ConversationType? {
        switch self {
        case .chat:
            return .chat
        case .stream:
            return .stream
        case .data, .UNRECOGNIZED(_), .none:
            return nil
        }
    }
}
