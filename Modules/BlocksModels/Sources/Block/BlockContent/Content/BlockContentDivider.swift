import ProtobufMessages

public struct BlockDivider: Hashable {
    public var style: Style
    
    public init(style: Style) {
        self.style = style
    }
    
    public init?(_ model: Anytype_Model_Block.Content.Div) {
        guard let style = BlockDivider.Style(model.style) else {
            return nil
        }
        
        self.style = style
    }

    
    public var asMiddleware: Anytype_Model_Block.OneOf_Content {
        .div(.with {
            $0.style = style.asMiddleware
        })
    }
}

extension BlockDivider {
    public enum Style {
        case line
        case dots
        
        public init?(_ model: Anytype_Model_Block.Content.Div.Style) {
            switch model {
            case .line: self =  .line
            case .dots: self =  .dots
            case .UNRECOGNIZED: return nil
            }
        }
        
        public var asMiddleware: Anytype_Model_Block.Content.Div.Style {
            switch self {
            case .line: return .line
            case .dots: return .dots
            }
        }
    }
}
