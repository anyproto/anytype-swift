import ProtobufMessages
import BlocksModels

extension Anytype_Model_Block.Content.Dataview {
    var blockContent: BlockContent {
        .dataView(
            BlockDataview(
                activeViewId: activeView,
                source: source,
                views: views.compactMap(\.asModel),
                relations: relations.map { RelationMetadata(middlewareRelation: $0) }
            )
        )
    }
}

extension Anytype_Model_Block.Content.Dataview.View {
    var asModel: DataviewView? {
        type.asModel.flatMap {
            DataviewView(
                id: id,
                name: name,
                type: $0,
                relations: relations.map(\.asModel),
                sorts: sorts,
                filters: filters
            )
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

extension Anytype_Model_Block.Content.Dataview.Relation {
    var asModel: DataviewViewRelation {
        DataviewViewRelation(key: key, isVisible: isVisible)
    }
}
