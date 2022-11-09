import AnytypeCore
import ProtobufMessages

public struct BlockDataview: Hashable {
    public var activeViewId: BlockId 
    public let source: [String]
    public let views: [DataviewView]
    public let relations: [RelationMetadata]
    public let groupOrders: [DataviewGroupOrder]
    public let objectOrders: [DataviewObjectOrder]
    
    public func updated(
        activeViewId: BlockId? = nil,
        source: [String]? = nil,
        views: [DataviewView]? = nil,
        relations: [RelationMetadata]? = nil,
        groupOrders: [DataviewGroupOrder]? = nil,
        objectOrders: [DataviewObjectOrder]? = nil
    ) -> BlockDataview {
        BlockDataview(
            activeViewId: activeViewId ?? self.activeViewId,
            source: source ?? self.source,
            views: views ?? self.views,
            relations: relations ?? self.relations,
            groupOrders: groupOrders ?? self.groupOrders,
            objectOrders: objectOrders ?? self.objectOrders
        )
    }


    public static var empty: BlockDataview {
        BlockDataview(
            activeViewId: "",
            source: [],
            views: [],
            relations: [],
            groupOrders: [],
            objectOrders: []
        )
    }

    var asMiddleware: MiddlewareDataview {
        MiddlewareDataview(
            source: source,
            views: views.map(\.asMiddleware),
            relations: relations.map(\.asMiddleware),
            activeView: activeViewId
        )
    }
}

public extension MiddlewareDataview {
    var blockContent: BlockContent {
        .dataView(asModel)
    }
    
    var asModel: BlockDataview {
        BlockDataview(
            activeViewId: activeView,
            source: source,
            views: views.compactMap(\.asModel),
            relations: relations.map { RelationMetadata(middlewareRelation: $0) },
            groupOrders: groupOrders,
            objectOrders: objectOrders
        )
    }
}
