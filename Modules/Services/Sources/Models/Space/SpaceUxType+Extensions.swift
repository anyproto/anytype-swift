import ProtobufMessages

public extension SpaceUxType {
    var isStream: Bool {
        switch self {
        case .stream:
            return true
        default:
            return false
        }
    }
    
    var isChat: Bool {
        switch self {
        case .chat:
            return true
        default:
            return false
        }
    }
    
    var isData: Bool {
        switch self {
        case .data:
            return true
        default:
            return false
        }
    }
}

