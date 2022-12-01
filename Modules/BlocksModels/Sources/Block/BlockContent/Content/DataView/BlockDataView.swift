import AnytypeCore
import ProtobufMessages

public struct BlockDataview: Hashable {
    public var activeViewId: BlockId 
    public let source: [String]
    public let views: [DataviewView]
    public let relationLinks: [RelationLink]
    public let groupOrders: [DataviewGroupOrder]
    public let objectOrders: [DataviewObjectOrder]
    
    public func updated(
        activeViewId: BlockId? = nil,
        source: [String]? = nil,
        views: [DataviewView]? = nil,
        relationLinks: [RelationLink]? = nil,
        groupOrders: [DataviewGroupOrder]? = nil,
        objectOrders: [DataviewObjectOrder]? = nil
    ) -> BlockDataview {
        BlockDataview(
            activeViewId: activeViewId ?? self.activeViewId,
            source: source ?? self.source,
            views: views ?? self.views,
            relationLinks: relationLinks ?? self.relationLinks,
            groupOrders: groupOrders ?? self.groupOrders,
            objectOrders: objectOrders ?? self.objectOrders
        )
    }

    public static var empty: BlockDataview {
        BlockDataview(
            activeViewId: "",
            source: [],
            views: [],
            relationLinks: [],
            groupOrders: [],
            objectOrders: []
        )
    }

    var asMiddleware: MiddlewareDataview {
        MiddlewareDataview(
            source: source,
            views: views.map(\.asMiddleware),
            activeView: activeViewId,
            groupOrders: groupOrders,
            objectOrders: objectOrders,
            relationLinks: relationLinks.map(\.asMiddleware)
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
            relationLinks: relationLinks.map { RelationLink(middlewareRelationLink: $0) },
            groupOrders: groupOrders,
            objectOrders: objectOrders
        )
    }
}
