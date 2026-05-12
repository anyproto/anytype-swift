import Foundation
import ProtobufMessages

public enum WidgetPosition:  Equatable, Hashable, Sendable {
    case end
    case above(widgetId: String)
    case below(widgetId: String)
    // First child of the context (used for personal-favorites where wrappers must
    // land at the doc root, not nested inside the `header` block).
    case innerFirst
}

extension WidgetPosition {

    var targetId: String {
        switch self {
        case .end, .innerFirst:
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
        case .innerFirst:
            return .innerFirst
        }
    }
}
