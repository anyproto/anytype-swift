import AnytypeCore
import ProtobufMessages

public struct BlockDataview: Hashable {
    public var activeViewId: BlockId 
    public let source: [String]
    public let views: [DataviewView]
    public let relations: [RelationMetadata]
    
    public init(
        activeViewId: BlockId,
        source: [String],
        views: [DataviewView],
        relations: [RelationMetadata]
    ) {
        self.activeViewId = activeViewId
        self.source = source
        self.views = views
        self.relations = relations
    }
    
    public func updated(views newViews: [DataviewView]) -> BlockDataview {
        BlockDataview(activeViewId: activeViewId, source: source, views: newViews, relations: relations)
    }
    
    public func updated(activeViewId newActiveViewId: BlockId) -> BlockDataview {
        BlockDataview(activeViewId: newActiveViewId, source: source, views: views, relations: relations)
    }
    
    public func updated(source newSource: [String]) -> BlockDataview {
        BlockDataview(activeViewId: activeViewId, source: newSource, views: views, relations: relations)
    }
    
    public func updated(relations newRelations: [RelationMetadata]) -> BlockDataview {
        BlockDataview(activeViewId: activeViewId, source: source, views: views, relations: newRelations)
    }
    
    public static var empty: BlockDataview {
        BlockDataview(activeViewId: "", source: [], views: [], relations: [])
    }
}


extension BlockDataview {
    public func relationsMetadataForView(_ view: DataviewView) -> [RelationMetadata] {
        return view.relations
            .filter { $0.isVisible }
            .map(\.key)
            .compactMap { key in
                relations.first { $0.key == key }
            }
    }
}
