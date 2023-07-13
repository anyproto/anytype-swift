import Foundation
import ProtobufMessages
import AnytypeCore

public enum WidgetLayoutError: Error {
    case valueUnrecognized
}

public extension Anytype_Model_Block.Content.Widget {
    var blockContent: BlockContent {
        get throws {
            .widget(BlockWidget(
                layout: try layout.asModel,
                limit: Int(limit),
                viewId: viewID
            ))
        }
    }
}

public extension Anytype_Model_Block.Content.Widget.Layout {
    var asModel: BlockWidget.Layout {
        get throws {
            switch self {
            case .link:
                return .link
            case .tree:
                return .tree
            case .list:
                return .list
            case .compactList:
                if FeatureFlags.compactListWidget {
                    return .compactList
                } else {
                    return .list
                }
            case .UNRECOGNIZED:
                anytypeAssertionFailure("UNRECOGNIZED layout type", info: ["type": "\(rawValue)"])
                throw WidgetLayoutError.valueUnrecognized
            }
        }
    }
}

public extension BlockWidget.Layout {
    var asMiddleware: Anytype_Model_Block.Content.Widget.Layout {
        switch self {
        case .link:
            return .link
        case .tree:
            return .tree
        case .list:
            return .list
        case .compactList:
            return .compactList
        }
    }
}

// Apply Events

public extension BlockWidget {
    func applyBlockSetWidgetEvent(data: Anytype_Event.Block.Set.Widget) -> Self {
        return BlockWidget(
            layout: (data.hasLayout ? (try? data.layout.value.asModel) : nil) ?? layout,
            limit: data.hasLimit ? Int(data.limit.value) : limit,
            viewId: data.hasViewID ? data.viewID.value : viewId
        )
    }
}
