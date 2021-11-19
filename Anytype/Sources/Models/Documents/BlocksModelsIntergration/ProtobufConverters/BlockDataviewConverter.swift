import ProtobufMessages
import BlocksModels

extension Anytype_Model_Block.Content.Dataview {
    var blockContent: BlockContent {
        .dataView(
            BlockDataview(
                source: source,
                activeView: activeView,
                views: views.compactMap(\.asModel)
            )
        )
    }
}

extension Anytype_Model_Block.Content.Dataview.View {
    var asModel: DataviewView? {
        type.asModel.flatMap {
            DataviewView(id: id, name: name, type: $0)
        }
    }
}

extension Anytype_Model_Block.Content.Dataview.View.TypeEnum {
    var asModel: DataviewViewType? {
        switch self {
        case .table: return .table
        case .list: return .list
        case .gallery: return .gallery
        case .kanban: return .kanban
        case .UNRECOGNIZED: return nil
        }
    }
}
