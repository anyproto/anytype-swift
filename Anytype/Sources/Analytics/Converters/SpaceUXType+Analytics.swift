import Services

extension SpaceType {
    var analyticsValue: String {
        switch self {
        case .chat:
            return "Chat"
        case .regular:
            return "Space"
        case .oneToOne:
            return "OneToOne"
        case .tech:
            return "Tech"
        case .unknown:
            return "Unknown"
        case .UNRECOGNIZED:
            return "UNRECOGNIZED"
        }
    }
}
