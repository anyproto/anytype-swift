import Foundation
import BlocksModels
import ProtobufMessages

extension Anytype_Model_Block.Content.Widget {
    var blockContent: BlockContent? {
        return layout.asModel.map { .widget(BlockWidget(layout: $0)) }
    }
}

extension Anytype_Model_Block.Content.Widget.Layout {
    var asModel: BlockWidget.Layout? {
        switch self {
        case .link:
            return .link
        case .tree:
            return .tree
        // TODO: Fix to list enum after middleware updates
        case .UNRECOGNIZED(2):
            return .list
        case .UNRECOGNIZED:
            return nil
        }
    }
}

extension BlockWidget.Layout {
    var asMiddleware: Anytype_Model_Block.Content.Widget.Layout {
        switch self {
        case .link:
            return .link
        case .tree:
            return .tree
        case .list:
            // TODO: Fix to list enum after middleware updates
            return .UNRECOGNIZED(2)
        }
    }
}
