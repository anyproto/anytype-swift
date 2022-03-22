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

