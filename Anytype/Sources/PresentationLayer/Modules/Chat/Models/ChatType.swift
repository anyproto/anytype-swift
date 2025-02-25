import Services

enum ConversationType {
    case chat
    case channel
    
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
            return .channel
        case .data, .UNRECOGNIZED(_):
            return nil
        }
    }
}
