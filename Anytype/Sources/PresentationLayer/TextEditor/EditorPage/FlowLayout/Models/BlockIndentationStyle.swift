import CoreFoundation


public enum BlockIndentationStyle: Hashable, Equatable {
    case `none`
    case quote
    case callout
    
    var padding: CGFloat {
        switch self {
        case .none:
            return LayoutConstants.Paddings.default
        case .quote:
            return LayoutConstants.Paddings.quote
        case .callout:
            return LayoutConstants.Paddings.quote
        }
    }
    
    var extraHeight: CGFloat {
        switch self {
        case .none:
            return 0
        case .quote, .callout:
            return LayoutConstants.Paddings.default
        }
    }
}
