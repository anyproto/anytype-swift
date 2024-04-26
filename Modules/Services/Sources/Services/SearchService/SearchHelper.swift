import ProtobufMessages
import SwiftProtobuf
import Foundation

public class SearchHelper {
    public static func sort(relation: BundledRelationKey, type: DataviewSort.TypeEnum) -> DataviewSort {
        var sort = DataviewSort()
        sort.relationKey = relation.rawValue
        sort.type = type
        
        return sort
    }
    
    public static func customSort(ids: [String]) -> DataviewSort {
        var sort = DataviewSort()
        sort.type = .custom
        sort.customOrder = ids.map { $0.protobufValue }
        
        return sort
    }
    
    public static func isArchivedFilter(isArchived: Bool) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .equal
        filter.value = isArchived.protobufValue
        filter.relationKey = BundledRelationKey.isArchived.rawValue
        filter.operator = .and
        
        return filter
    }
    
    public static func isFavoriteFilter(isFavorite: Bool) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .equal
        filter.value = isFavorite.protobufValue
        filter.relationKey = BundledRelationKey.isFavorite.rawValue
        filter.operator = .and
        
        return filter
    }
    
    public static func isDeletedFilter(isDeleted: Bool) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .equal
        filter.value = isDeleted.protobufValue
        filter.relationKey = BundledRelationKey.isDeleted.rawValue
        filter.operator = .and
        
        return filter
    }
    
    public static func notHiddenFilter() -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .equal
        filter.value = false.protobufValue
        filter.relationKey = BundledRelationKey.isHidden.rawValue
        filter.operator = .and
        
        return filter
    }
    
    public static func lastOpenedDateNotNilFilter() -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .notEmpty
        filter.value = nil
        filter.relationKey = BundledRelationKey.lastOpenedDate.rawValue
        filter.operator = .and
        
        return filter
    }
    
    public static func lastModifiedDateFrom(_ date: Date) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .greaterOrEqual
        filter.value = date.timeIntervalSince1970.protobufValue
        filter.relationKey = BundledRelationKey.lastModifiedDate.rawValue
        filter.operator = .and
        
        return filter
    }
    
    public static func typeFilter(typeIds: [String]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .in
        filter.value = typeIds.protobufValue
        filter.relationKey = BundledRelationKey.type.rawValue
        filter.operator = .and
        
        return filter
    }
    
    public static func excludedTypeFilter(_ typeIds: [String]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .notIn
        filter.value = typeIds.protobufValue
        filter.relationKey = BundledRelationKey.type.rawValue
        filter.operator = .and
        
        return filter
    }
    
    public static func layoutFilter(_ layouts: [DetailsLayout]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .in
        filter.value = layouts.map(\.rawValue).protobufValue
        filter.relationKey = BundledRelationKey.layout.rawValue
        filter.operator = .and
        
        return filter
    }
    
    public static func excludedLayoutFilter(_ layouts: [DetailsLayout]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .notIn
        filter.value = layouts.map(\.rawValue).protobufValue
        filter.relationKey = BundledRelationKey.layout.rawValue
        filter.operator = .and
        
        return filter
    }
    
    public static func recomendedLayoutFilter(_ layouts: [DetailsLayout]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .in
        filter.value = layouts.map(\.rawValue).protobufValue
        filter.relationKey = BundledRelationKey.recommendedLayout.rawValue
        filter.operator = .and
        
        return filter
    }
    
    public static func supportedIdsFilter(_ typeIds: [String]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .in
        filter.value = typeIds.protobufValue
        filter.relationKey = BundledRelationKey.id.rawValue
        filter.operator = .and
        
        return filter
    }
    
    public static func sharedObjectsFilters() -> [DataviewFilter] {
        var spaceFilter = DataviewFilter()
        spaceFilter.condition = .notEmpty
        spaceFilter.value = nil
        spaceFilter.relationKey = BundledRelationKey.spaceId.rawValue
        spaceFilter.operator = .and
   
        var highlightedFilter = DataviewFilter()
        highlightedFilter.condition = .equal
        highlightedFilter.value = true
        highlightedFilter.relationKey = BundledRelationKey.isHighlighted.rawValue
        highlightedFilter.operator = .and
        
        return [
            spaceFilter,
            highlightedFilter
        ]
    }
    
    public static func excludedIdsFilter(_ ids: [String]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .notIn
        filter.value = ids.protobufValue
        
        filter.relationKey = BundledRelationKey.id.rawValue
        filter.operator = .and
        
        return filter
    }
    
    public static func relationKey(_ relationKey: String) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .equal
        filter.value = relationKey.protobufValue
        
        filter.relationKey = BundledRelationKey.relationKey.rawValue
        filter.operator = .and
        
        return filter
    }
    
    public static func excludedRelationKeys(_ relationKeys: [String]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .notIn
        filter.value = relationKeys.protobufValue
        
        filter.relationKey = BundledRelationKey.relationKey.rawValue
        filter.operator = .and
        
        return filter
    }

    public static func templatesFilters(type: String, spaceId spaceIdValue: String) -> [DataviewFilter] {
        [
            isArchivedFilter(isArchived: false),
            isDeletedFilter(isDeleted: false),
            templateScheme(include: true),
            templateTypeFilter(type: type),
            spaceId(spaceIdValue)
        ]
    }
    
    public static func spaceId(_ spaceId: String) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .equal
        filter.value = spaceId.protobufValue
        
        filter.relationKey = BundledRelationKey.spaceId.rawValue
        filter.operator = .and
        
        return filter
    }
    
    public static func spaceIds(_ spaceIds: [String]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .in
        filter.value = spaceIds.protobufValue
        
        filter.relationKey = BundledRelationKey.spaceId.rawValue
        filter.operator = .and
        
        return filter
    }
    
    public static func fileSyncStatus(_ status: FileSyncStatus) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .equal
        filter.value = status.rawValue.protobufValue
        filter.relationKey = BundledRelationKey.fileSyncStatus.rawValue
        filter.operator = .and
        
        return filter
    }
    
    public static func excludeObjectRestriction(_ restriction: ObjectRestriction) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .notIn
        filter.value = restriction.rawValue.protobufValue
        filter.relationKey = BundledRelationKey.restrictions.rawValue
        filter.operator = .and
        
        return filter
    }
    
    public static func relationReadonlyValue(_ value: Bool) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .equal
        filter.value = value.protobufValue
        filter.relationKey = BundledRelationKey.relationReadonlyValue.rawValue
        filter.operator = .and
        
        return filter
    }
    
    public static func spaceAccountStatusExcludeFilter(_ status: SpaceStatus...) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .notIn
        filter.value = status.map { $0.toMiddleware.rawValue }.protobufValue
        filter.relationKey = BundledRelationKey.spaceAccountStatus.rawValue
        filter.operator = .and
        
        return filter
    }
    
    public static func spaceLocalStatusFilter(_ status: SpaceStatus) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .equal
        filter.value = status.toMiddleware.rawValue.protobufValue
        filter.relationKey = BundledRelationKey.spaceLocalStatus.rawValue
        filter.operator = .and
        
        return filter
    }
    
    public static func templateScheme(include: Bool) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = include ? .equal : .notEqual
        filter.relationKey = "\(BundledRelationKey.type.rawValue).\(BundledRelationKey.uniqueKey.rawValue)"
        filter.value = ObjectTypeUniqueKey.template.value.protobufValue

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
}
