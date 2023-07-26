import ProtobufMessages
import SwiftProtobuf
import Services

class SearchHelper {
    static func sort(relation: BundledRelationKey, type: DataviewSort.TypeEnum) -> DataviewSort {
        var sort = DataviewSort()
        sort.relationKey = relation.rawValue
        sort.type = type
        
        return sort
    }
    
    static func customSort(ids: [String]) -> DataviewSort {
        var sort = DataviewSort()
        sort.type = .custom
        sort.customOrder = ids.map { $0.protobufValue }
        
        return sort
    }
    
    static func isArchivedFilter(isArchived: Bool) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .equal
        filter.value = isArchived.protobufValue
        filter.relationKey = BundledRelationKey.isArchived.rawValue
        filter.operator = .and
        
        return filter
    }
    
    static func isFavoriteFilter(isFavorite: Bool) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .equal
        filter.value = isFavorite.protobufValue
        filter.relationKey = BundledRelationKey.isFavorite.rawValue
        filter.operator = .and
        
        return filter
    }
    
    static func isDeletedFilter(isDeleted: Bool) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .equal
        filter.value = isDeleted.protobufValue
        filter.relationKey = BundledRelationKey.isDeleted.rawValue
        filter.operator = .and
        
        return filter
    }
    
    static func notHiddenFilter() -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .equal
        filter.value = false.protobufValue
        filter.relationKey = BundledRelationKey.isHidden.rawValue
        filter.operator = .and
        
        return filter
    }
    
    static func lastOpenedDateNotNilFilter() -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .notEmpty
        filter.value = nil
        filter.relationKey = BundledRelationKey.lastOpenedDate.rawValue
        filter.operator = .and
        
        return filter
    }
    
    static func typeFilter(typeIds: [String]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .in
        filter.value = typeIds.protobufValue
        filter.relationKey = BundledRelationKey.type.rawValue
        filter.operator = .and
        
        return filter
    }
    
    static func excludedTypeFilter(_ typeIds: [String]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .notIn
        filter.value = typeIds.protobufValue
        filter.relationKey = BundledRelationKey.type.rawValue
        filter.operator = .and
        
        return filter
    }
    
    static func layoutFilter(_ layouts: [DetailsLayout]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .in
        filter.value = layouts.map(\.rawValue).protobufValue
        filter.relationKey = BundledRelationKey.layout.rawValue
        filter.operator = .and
        
        return filter
    }
    
    static func recomendedLayoutFilter(_ layouts: [DetailsLayout]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .in
        filter.value = layouts.map(\.rawValue).protobufValue
        filter.relationKey = BundledRelationKey.recommendedLayout.rawValue
        filter.operator = .and
        
        return filter
    }
    
    static func supportedIdsFilter(_ typeIds: [String]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .in
        filter.value = typeIds.protobufValue
        filter.relationKey = BundledRelationKey.id.rawValue
        filter.operator = .and
        
        return filter
    }
    
    static func sharedObjectsFilters() -> [DataviewFilter] {
        var workspaceFilter = DataviewFilter()
        workspaceFilter.condition = .notEmpty
        workspaceFilter.value = nil
        workspaceFilter.relationKey = BundledRelationKey.workspaceId.rawValue
        workspaceFilter.operator = .and
   
        var highlightedFilter = DataviewFilter()
        highlightedFilter.condition = .equal
        highlightedFilter.value = true
        highlightedFilter.relationKey = BundledRelationKey.isHighlighted.rawValue
        highlightedFilter.operator = .and
        
        return [
            workspaceFilter,
            highlightedFilter
        ]
    }
    
    static func excludedIdsFilter(_ ids: [String]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .notIn
        filter.value = ids.protobufValue
        
        filter.relationKey = BundledRelationKey.id.rawValue
        filter.operator = .and
        
        return filter
    }
    
    static func relationKey(_ relationKey: String) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .equal
        filter.value = relationKey.protobufValue
        
        filter.relationKey = BundledRelationKey.relationKey.rawValue
        filter.operator = .and
        
        return filter
    }
    
    static func excludedRelationKeys(_ relationKeys: [String]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .notIn
        filter.value = relationKeys.protobufValue
        
        filter.relationKey = BundledRelationKey.relationKey.rawValue
        filter.operator = .and
        
        return filter
    }

    static func templatesFilters(type: ObjectTypeId, spaceId spaceIdValue: String) -> [DataviewFilter] {
        [
            isArchivedFilter(isArchived: false),
            isDeletedFilter(isDeleted: false),
            templateScheme(),
            templateTypeFilter(type: type.rawValue),
            spaceId(spaceIdValue)
        ]
    }
    
    static func workspaceId(_ workspaceId: String) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .equal
        filter.value = workspaceId.protobufValue
        
        filter.relationKey = BundledRelationKey.workspaceId.rawValue
        filter.operator = .and
        
        return filter
    }
    
    static func workspaceIds(_ workspaceIds: [String]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .in
        filter.value = workspaceIds.protobufValue
        
        filter.relationKey = BundledRelationKey.workspaceId.rawValue
        filter.operator = .and
        
        return filter
    }
    
    static func spaceId(_ spaceId: String) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .equal
        filter.value = spaceId.protobufValue
        
        filter.relationKey = BundledRelationKey.spaceId.rawValue
        filter.operator = .and
        
        return filter
    }
    
    static func fileSyncStatus(_ status: FileSyncStatus) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .equal
        filter.value = status.rawValue.protobufValue
        filter.relationKey = BundledRelationKey.fileSyncStatus.rawValue
        filter.operator = .and
        
        return filter
    }
    
    // MARK: - Private

    private static func templateTypeFilter(type: String) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .equal
        filter.value = type.protobufValue
        filter.relationKey = BundledRelationKey.targetObjectType.rawValue

        return filter
    }

    private static func templateScheme() -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .equal
        filter.relationKey = BundledRelationKey.type.rawValue
        filter.value = ObjectTypeId.bundled(.template).rawValue.protobufValue

        return filter
    }
    
}
