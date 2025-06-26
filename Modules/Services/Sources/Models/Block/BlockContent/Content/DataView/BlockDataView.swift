import AnytypeCore
import ProtobufMessages

public struct BlockDataview: Hashable, Sendable {
    public var activeViewId: String
    public let views: [DataviewView]
    public let relationLinks: [PropertyLink]
    public let groupOrders: [DataviewGroupOrder]
    public let objectOrders: [DataviewObjectOrder]
    public let targetObjectID: String
    public let isCollection: Bool
    
    public func updated(
        activeViewId: String? = nil,
        views: [DataviewView]? = nil,
        relationLinks: [PropertyLink]? = nil,
        groupOrders: [DataviewGroupOrder]? = nil,
        objectOrders: [DataviewObjectOrder]? = nil,
        targetObjectID: String? = nil,
        isCollection: Bool? = nil
    ) -> BlockDataview {
        BlockDataview(
            activeViewId: activeViewId ?? self.activeViewId,
            views: views ?? self.views,
            relationLinks: relationLinks ?? self.relationLinks,
            groupOrders: groupOrders ?? self.groupOrders,
            objectOrders: objectOrders ?? self.objectOrders,
            targetObjectID: targetObjectID ?? self.targetObjectID,
            isCollection: isCollection ?? self.isCollection
        )
    }

    public static var empty: BlockDataview {
        BlockDataview(
            activeViewId: "",
            views: [],
            relationLinks: [],
            groupOrders: [],
            objectOrders: [],
            targetObjectID: "",
            isCollection: false
        )
    }
    
    public var asMiddleware: Anytype_Model_Block.Content.Dataview {
        Anytype_Model_Block.Content.Dataview.with {
            $0.views = views.map { $0.asMiddleware }
            $0.activeView = activeViewId
            $0.groupOrders = groupOrders
            $0.objectOrders = objectOrders
            $0.relationLinks = relationLinks.map { $0.asMiddleware }
            $0.targetObjectID = targetObjectID
            $0.isCollection = isCollection
        }
    }
}

public extension MiddlewareDataview {
    var blockContent: BlockContent {
        .dataView(asModel)
    }
    
    var asModel: BlockDataview {
        BlockDataview(
            activeViewId: activeView,
            views: views.compactMap(\.asModel),
            relationLinks: relationLinks.map { PropertyLink(middlewareRelationLink: $0) },
            groupOrders: groupOrders,
            objectOrders: objectOrders,
            targetObjectID: targetObjectID,
            isCollection: isCollection
        )
    }
}
