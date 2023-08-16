import Foundation
import ProtobufMessages

enum WidgetPosition: Equatable, Hashable {
    case end
    case below(widgetId: String)
    
    var targetId: String {
        switch self {
        case .end:
            return ""
        case .below(let widgetId):
            return widgetId
        }
    }
    
    var middlePosition: Anytype_Model_Block.Position {
        switch self {
        case .end:
            return .none
        case .below:
            return .bottom
        }
    }
}
