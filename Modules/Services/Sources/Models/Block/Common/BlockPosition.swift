import ProtobufMessages

public enum BlockPosition {
    case none
    case top, bottom
    case left, right
    case inner
    case replace
    
    public init?(_ value: Anytype_Model_Block.Position) {
        switch value {
        case .none: self = BlockPosition.none
        case .top: self = .top
        case .bottom: self = .bottom
        case .left: self = .left
        case .right: self = .right
        case .inner: self = .inner
        case .replace: self = .replace
        default: return nil
        }
    }

    public var asMiddleware: Anytype_Model_Block.Position {
        switch self {
        case .none: return .none
        case .top: return .top
        case .bottom: return .bottom
        case .left: return .left
        case .right: return .right
        case .inner: return .inner
        case .replace: return .replace
        }
    }
}
