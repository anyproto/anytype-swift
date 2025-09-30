import ProtobufMessages
import SwiftProtobuf
import Foundation

public typealias EmptyPlacement = Anytype_Model_Block.Content.Dataview.Sort.EmptyType

public class SearchHelper {
    public static func sort(
        relation: BundledPropertyKey,
        type: DataviewSort.TypeEnum,
        noCollate: Bool = false,
        includeTime: Bool = false,
        emptyPlacement: EmptyPlacement? = nil
    ) -> DataviewSort {
        sort(relationKey: relation.rawValue, type: type, noCollate: noCollate, includeTime: includeTime, emptyPlacement: emptyPlacement)
    }
    
    public static func sort(relationKey: String, type: DataviewSort.TypeEnum, noCollate: Bool = false, includeTime: Bool = false, emptyPlacement: EmptyPlacement? = nil) -> DataviewSort {
        var sort = DataviewSort()
        sort.relationKey = relationKey
        sort.type = type
        sort.noCollate = noCollate // https://linear.app/anytype/issue/IOS-3813/add-nocollate-parameter-to-sort-model-for-spaceorder
        sort.includeTime = includeTime
        if let emptyPlacement { sort.emptyPlacement = emptyPlacement }
         
        return sort
    }
    
    public static func customSort(relationKey: String, values: [String]) -> DataviewSort {
        var sort = DataviewSort()
        sort.type = .custom
        sort.relationKey = relationKey
        sort.customOrder = values.map { $0.protobufValue }
        
        return sort
    }
    
    public static func isArchivedFilter(isArchived: Bool) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = isArchived ? .equal : .notEqual
        filter.value = true
        filter.relationKey = BundledPropertyKey.isArchived.rawValue
        
        return filter
    }
    
    public static func isDeletedFilter(isDeleted: Bool) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = isDeleted ? .equal : .notEqual
        filter.value = true
        filter.relationKey = BundledPropertyKey.isDeleted.rawValue
        
        return filter
    }
    
    public static func isHidden(_ isHidden: Bool) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = isHidden ? .equal : .notEqual
        filter.value = true
        filter.relationKey = BundledPropertyKey.isHidden.rawValue
        
        return filter
    }
    
    public static func lastOpenedDateNotNilFilter() -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .notEmpty
        filter.value = nil
        filter.relationKey = BundledPropertyKey.lastOpenedDate.rawValue
        
        return filter
    }
    
    public static func lastModifiedDateFrom(_ date: Date) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .greaterOrEqual
        filter.value = date.timeIntervalSince1970.protobufValue
        filter.relationKey = BundledPropertyKey.lastModifiedDate.rawValue
        
        return filter
    }
    
    public static func typeFilter(_ typeIds: [String]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .in
        filter.value = typeIds.protobufValue
        filter.relationKey = BundledPropertyKey.type.rawValue
        
        return filter
    }
    
    public static func excludedTypeFilter(_ typeIds: [String]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .notIn
        filter.value = typeIds.protobufValue
        filter.relationKey = BundledPropertyKey.type.rawValue
        
        return filter
    }
    
    public static func layoutFilter(_ layouts: [DetailsLayout]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .in
        filter.value = layouts.map(\.rawValue).protobufValue
        filter.relationKey = BundledPropertyKey.resolvedLayout.rawValue
        
        return filter
    }
    
    public static func uniqueKeyFilter(key: String, include: Bool) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = include ? .equal : .notEqual
        filter.relationKey = BundledPropertyKey.uniqueKey.rawValue
        filter.value = key.protobufValue

        return filter
    }
    
    public static func participantStatusFilter(_ status: ParticipantStatus...) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .in
        filter.value = status.map(\.rawValue).protobufValue
        filter.relationKey = BundledPropertyKey.participantStatus.rawValue
        
        return filter
    }
    
    public static func excludedLayoutFilter(_ layouts: [DetailsLayout]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .notIn
        filter.value = layouts.map(\.rawValue).protobufValue
        filter.relationKey = BundledPropertyKey.resolvedLayout.rawValue
        
        return filter
    }
    
    public static func recomendedLayoutFilter(_ layouts: [DetailsLayout]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .in
        filter.value = layouts.map(\.rawValue).protobufValue
        filter.relationKey = BundledPropertyKey.recommendedLayout.rawValue
        
        return filter
    }
    
    public static func includeIdsFilter(_ typeIds: [String]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .in
        filter.value = typeIds.protobufValue
        filter.relationKey = BundledPropertyKey.id.rawValue
        
        return filter
    }
    
    public static func excludedIdsFilter(_ ids: [String]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .notIn
        filter.value = ids.protobufValue
        
        filter.relationKey = BundledPropertyKey.id.rawValue
        
        return filter
    }
    
    public static func relationKey(_ relationKey: String) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .equal
        filter.value = relationKey.protobufValue
        
        filter.relationKey = BundledPropertyKey.relationKey.rawValue
        
        return filter
    }
    
    public static func excludedRelationKeys(_ relationKeys: [String]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .notIn
        filter.value = relationKeys.protobufValue
        
        filter.relationKey = BundledPropertyKey.relationKey.rawValue
        
        return filter
    }

    public static func templatesFilters(type: String) -> [DataviewFilter] {
        [
            isArchivedFilter(isArchived: false),
            isDeletedFilter(isDeleted: false),
            templateScheme(include: true),
            templateTypeFilter(type: type)
        ]
    }
    
    public static func objectsIds(_ objectsIds: [String]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .in
        filter.value = objectsIds.protobufValue
        
        filter.relationKey = BundledPropertyKey.id.rawValue
        
        return filter
    }
    
    public static func identity(_ identityId: String) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .equal
        filter.value = identityId.protobufValue
        
        filter.relationKey = BundledPropertyKey.identity.rawValue
        
        return filter
    }
    
    public static func fileSyncStatus(_ status: FileSyncStatus) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .equal
        filter.value = status.rawValue.protobufValue
        filter.relationKey = BundledPropertyKey.fileSyncStatus.rawValue
        
        return filter
    }
    
    public static func excludeObjectRestriction(_ restriction: ObjectRestriction) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .notIn
        filter.value = restriction.rawValue.protobufValue
        filter.relationKey = BundledPropertyKey.restrictions.rawValue
        
        return filter
    }
    
    public static func relationReadonlyValue(_ value: Bool) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .equal
        filter.value = value.protobufValue
        filter.relationKey = BundledPropertyKey.relationReadonlyValue.rawValue
        
        return filter
    }
    
    public static func spaceAccountStatusExcludeFilter(_ statuses: SpaceStatus...) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .notIn
        filter.value = statuses.map { $0.rawValue }.protobufValue
        filter.relationKey = BundledPropertyKey.spaceAccountStatus.rawValue
        
        return filter
    }
    
    public static func spaceLocalStatusFilter(_ status: SpaceStatus) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .equal
        filter.value = status.rawValue.protobufValue
        filter.relationKey = BundledPropertyKey.spaceLocalStatus.rawValue
        
        return filter
    }
    
    public static func templateScheme(include: Bool) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = include ? .equal : .notEqual
        filter.relationKey = "\(BundledPropertyKey.type.rawValue).\(BundledPropertyKey.uniqueKey.rawValue)"
        filter.value = ObjectTypeUniqueKey.template.value.protobufValue

        return filter
    }
    
    public static func filterOutTypeType() -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .notEqual
        filter.relationKey = "\(BundledPropertyKey.uniqueKey.rawValue)"
        filter.value = ObjectTypeUniqueKey.objectType.value.protobufValue

        return filter
    }
    
    public static func isHiddenDiscovery(_ isHidden: Bool) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = isHidden ? .equal : .notEqual
        filter.value = true
        
        filter.relationKey = BundledPropertyKey.isHiddenDiscovery.rawValue
        
        return filter
    }
    
    public static func notHiddenFilters(isArchive: Bool = false, hideHiddenDescoveryFiles: Bool = true) -> [DataviewFilter] {
        .builder {
            SearchHelper.isHidden(false)
            if hideHiddenDescoveryFiles { SearchHelper.isHiddenDiscovery(false) }
            SearchHelper.isDeletedFilter(isDeleted: false)
            SearchHelper.isArchivedFilter(isArchived: isArchive)
            SearchHelper.filterOutTypeType()
        }
    }
    
    public static func onlyUnlinked() -> [DataviewFilter] {
        .builder {
            SearchHelper.emptyLinks()
            SearchHelper.emptyBacklinks()
        }
    }
    
    public static func setOfType(typeId: String) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .equal
        filter.value = typeId.protobufValue
        
        filter.relationKey = BundledPropertyKey.setOf.rawValue
        
        return filter
    }
    
    public static func name(_ name: String) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .like
        filter.value = name.protobufValue
        
        filter.relationKey = BundledPropertyKey.name.rawValue
        
        return filter
    }
    
    // MARK: - Private

    private static func templateTypeFilter(type: String) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .equal
        filter.value = type.protobufValue
        filter.relationKey = BundledPropertyKey.targetObjectType.rawValue

        return filter
    }
    
    private static func emptyLinks() -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .empty
        filter.relationKey = BundledPropertyKey.links.rawValue
        
        return filter
    }
    
    private static func emptyBacklinks() -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .empty
        filter.relationKey = BundledPropertyKey.backlinks.rawValue
        
        return filter
    }
}
