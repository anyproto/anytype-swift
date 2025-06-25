import Services

extension SpaceUxType {
    var analyticsValue: String {
        switch self {
        case .chat:
            return "chat"
        case .data:
            return "data"
        case .stream:
            return "stream"
        case .UNRECOGNIZED:
            return "UNRECOGNIZED"
        }
    }
}
