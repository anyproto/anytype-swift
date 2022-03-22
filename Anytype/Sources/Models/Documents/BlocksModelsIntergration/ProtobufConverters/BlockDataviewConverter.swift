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
