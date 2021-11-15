import ProtobufMessages
import SwiftProtobuf
import BlocksModels

class SearchHelper {
    static func sort(relation: RelationKey, type: Anytype_Model_Block.Content.Dataview.Sort.TypeEnum) -> Anytype_Model_Block.Content.Dataview.Sort {
        var sort = Anytype_Model_Block.Content.Dataview.Sort()
        sort.relationKey = relation.rawValue
        sort.type = type
        
        return sort
    }
    
    static func isArchivedFilter(isArchived: Bool) -> Anytype_Model_Block.Content.Dataview.Filter {
        var filter = Anytype_Model_Block.Content.Dataview.Filter()
        filter.condition = .equal
        filter.value = isArchived.protobufValue
        filter.relationKey = RelationKey.isArchived.rawValue
        filter.operator = .and
        
        return filter
    }
    
    static func notHiddenFilter() -> Anytype_Model_Block.Content.Dataview.Filter {
        var filter = Anytype_Model_Block.Content.Dataview.Filter()
        filter.condition = .equal
        filter.value = false.protobufValue
        filter.relationKey = RelationKey.isHidden.rawValue
        filter.operator = .and
        
        return filter
    }
    
    static func typeFilter(typeUrls: [String]) -> Anytype_Model_Block.Content.Dataview.Filter {
        var filter = Anytype_Model_Block.Content.Dataview.Filter()
        filter.condition = .in
        filter.value = typeUrls.protobufValue
        filter.relationKey = RelationKey.type.rawValue
        filter.operator = .and
        
        return filter
    }
    
    static func supportedObjectTypeUrlsFilter(_ typeUrls: [String]) -> Anytype_Model_Block.Content.Dataview.Filter {
        var filter = Anytype_Model_Block.Content.Dataview.Filter()
        filter.condition = .in
        filter.value = typeUrls.protobufValue
        filter.relationKey = RelationKey.id.rawValue
        filter.operator = .and
        
        return filter
    }
    
    static func sharedObjectsFilters() -> [Anytype_Model_Block.Content.Dataview.Filter] {
        var workspaceFilter = Anytype_Model_Block.Content.Dataview.Filter()
        workspaceFilter.condition = .notEmpty
        workspaceFilter.value = nil
        workspaceFilter.relationKey = RelationKey.workspaceId.rawValue
        workspaceFilter.operator = .and
   
        var highlightedFilter = Anytype_Model_Block.Content.Dataview.Filter()
        highlightedFilter.condition = .equal
        highlightedFilter.value = true
        highlightedFilter.relationKey = RelationKey.isHighlighted.rawValue
        highlightedFilter.operator = .and
        
        return [
            workspaceFilter,
            highlightedFilter
        ]
    }
    
    static func excludedObjectTypeUrlFilter(_ typeUrl: String) -> Anytype_Model_Block.Content.Dataview.Filter {
        var filter = Anytype_Model_Block.Content.Dataview.Filter()
        filter.condition = .notEqual
        filter.value = typeUrl.protobufValue
        
        filter.relationKey = RelationKey.id.rawValue
        filter.operator = .and
        
        return filter
    }
}
