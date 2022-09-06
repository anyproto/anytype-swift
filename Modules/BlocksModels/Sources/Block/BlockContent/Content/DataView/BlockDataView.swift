import AnytypeCore
import ProtobufMessages

public struct BlockDataview: Hashable {
    public var activeViewId: BlockId 
    public let source: [String]
    public let views: [DataviewView]
    public let relationLinks: [RelationLink]
    
    public func updated(
        activeViewId: BlockId? = nil,
        source: [String]? = nil,
        views: [DataviewView]? = nil,
        relationLinks: [RelationLink]? = nil
    ) -> BlockDataview {
        BlockDataview(
            activeViewId: activeViewId ?? self.activeViewId,
            source: source ?? self.source,
            views: views ?? self.views,
            relationLinks: relationLinks ?? self.relationLinks
        )
    }

    public static var empty: BlockDataview {
        BlockDataview(activeViewId: "", source: [], views: [], relationLinks: [])
    }

    var asMiddleware: MiddlewareDataview {
        MiddlewareDataview(
            source: source,
            views: views.map(\.asMiddleware),
            activeView: activeViewId,
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
            relationLinks: relationLinks.map { RelationLink(middlewareRelationLink: $0) }
        )
    }
}
