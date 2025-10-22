import Services

extension SpaceUxType {
    var analyticsValue: String {
        switch self {
        case .chat:
            return "Chat"
        case .data:
            return "Space"
        case .stream:
            return "Stream"
        case .UNRECOGNIZED:
            return "UNRECOGNIZED"
        case .none:
            return "None"
        }
    }
}
