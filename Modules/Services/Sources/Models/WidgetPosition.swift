import Foundation
import ProtobufMessages

public enum WidgetPosition:  Equatable, Hashable, Sendable {
    case end
    case above(widgetId: String)
    case below(widgetId: String)
}

extension WidgetPosition {
    
    var targetId: String {
        switch self {
        case .end:
            return ""
        case .above(let widgetId), .below(let widgetId):
            return widgetId
        }
    }
    
    var middlePosition: Anytype_Model_Block.Position {
        switch self {
        case .end:
            return .none
        case .above:
            return .top
        case .below:
            return .bottom
        }
    }
}
