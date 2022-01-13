public enum LayoutAlignment: Int, CaseIterable, Hashable {
    case left
    case center
    case right
}

public extension LayoutAlignment {
    var name: String {
        switch self {
        case .left:
            return "left"
        case .center:
            return "center"
        case .right:
            return "right"
        }
    }
}
