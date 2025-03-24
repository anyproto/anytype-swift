import ProtobufMessages
import SwiftProtobuf
import Foundation

public typealias EmptyPlacement = Anytype_Model_Block.Content.Dataview.Sort.EmptyType

public class SearchHelper {
    public static func sort(
        relation: BundledRelationKey,
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
    
    public static func customSort(ids: [String]) -> DataviewSort {
        var sort = DataviewSort()
        sort.type = .custom
        sort.customOrder = ids.map { $0.protobufValue }
        
        return sort
    }
    
    public static func isArchivedFilter(isArchived: Bool) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = isArchived ? .equal : .notEqual
        filter.value = true
        filter.relationKey = BundledRelationKey.isArchived.rawValue
        
        return filter
    }
    
    public static func isDeletedFilter(isDeleted: Bool) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = isDeleted ? .equal : .notEqual
        filter.value = true
        filter.relationKey = BundledRelationKey.isDeleted.rawValue
        
        return filter
    }
    
    public static func isHidden(_ isHidden: Bool) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = isHidden ? .equal : .notEqual
        filter.value = true
        filter.relationKey = BundledRelationKey.isHidden.rawValue
        
        return filter
    }
    
    public static func lastOpenedDateNotNilFilter() -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .notEmpty
        filter.value = nil
        filter.relationKey = BundledRelationKey.lastOpenedDate.rawValue
        
        return filter
    }
    
    public static func lastModifiedDateFrom(_ date: Date) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .greaterOrEqual
        filter.value = date.timeIntervalSince1970.protobufValue
        filter.relationKey = BundledRelationKey.lastModifiedDate.rawValue
        
        return filter
    }
    
    public static func typeFilter(_ typeIds: [String]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .in
        filter.value = typeIds.protobufValue
        filter.relationKey = BundledRelationKey.type.rawValue
        
        return filter
    }
    
    public static func excludedTypeFilter(_ typeIds: [String]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .notIn
        filter.value = typeIds.protobufValue
        filter.relationKey = BundledRelationKey.type.rawValue
        
        return filter
    }
    
    public static func layoutFilter(_ layouts: [DetailsLayout]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .in
        filter.value = layouts.map(\.rawValue).protobufValue
        filter.relationKey = BundledRelationKey.resolvedLayout.rawValue
        
        return filter
    }
    
    public static func uniqueKeyFilter(key: String, include: Bool) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = include ? .equal : .notEqual
        filter.relationKey = BundledRelationKey.uniqueKey.rawValue
        filter.value = key.protobufValue

        return filter
    }
    
    public static func participantStatusFilter(_ status: ParticipantStatus...) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .in
        filter.value = status.map(\.rawValue).protobufValue
        filter.relationKey = BundledRelationKey.participantStatus.rawValue
        
        return filter
    }
    
    public static func excludedLayoutFilter(_ layouts: [DetailsLayout]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .notIn
        filter.value = layouts.map(\.rawValue).protobufValue
        filter.relationKey = BundledRelationKey.resolvedLayout.rawValue
        
        return filter
    }
    
    public static func recomendedLayoutFilter(_ layouts: [DetailsLayout]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .in
        filter.value = layouts.map(\.rawValue).protobufValue
        filter.relationKey = BundledRelationKey.recommendedLayout.rawValue
        
        return filter
    }
    
    public static func includeIdsFilter(_ typeIds: [String]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .in
        filter.value = typeIds.protobufValue
        filter.relationKey = BundledRelationKey.id.rawValue
        
        return filter
    }
    
    public static func excludedIdsFilter(_ ids: [String]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .notIn
        filter.value = ids.protobufValue
        
        filter.relationKey = BundledRelationKey.id.rawValue
        
        return filter
    }
    
    public static func relationKey(_ relationKey: String) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .equal
        filter.value = relationKey.protobufValue
        
        filter.relationKey = BundledRelationKey.relationKey.rawValue
        
        return filter
    }
    
    public static func excludedRelationKeys(_ relationKeys: [String]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .notIn
        filter.value = relationKeys.protobufValue
        
        filter.relationKey = BundledRelationKey.relationKey.rawValue
        
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
        
        filter.relationKey = BundledRelationKey.id.rawValue
        
        return filter
    }
    
    public static func identity(_ identityId: String) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .equal
        filter.value = identityId.protobufValue
        
        filter.relationKey = BundledRelationKey.identity.rawValue
        
        return filter
    }
    
    public static func fileSyncStatus(_ status: FileSyncStatus) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .equal
        filter.value = status.rawValue.protobufValue
        filter.relationKey = BundledRelationKey.fileSyncStatus.rawValue
        
        return filter
    }
    
    public static func excludeObjectRestriction(_ restriction: ObjectRestriction) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .notIn
        filter.value = restriction.rawValue.protobufValue
        filter.relationKey = BundledRelationKey.restrictions.rawValue
        
        return filter
    }
    
    public static func relationReadonlyValue(_ value: Bool) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .equal
        filter.value = value.protobufValue
        filter.relationKey = BundledRelationKey.relationReadonlyValue.rawValue
        
        return filter
    }
    
    public static func spaceAccountStatusExcludeFilter(_ statuses: SpaceStatus...) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .notIn
        filter.value = statuses.map { $0.rawValue }.protobufValue
        filter.relationKey = BundledRelationKey.spaceAccountStatus.rawValue
        
        return filter
    }
    
    public static func spaceLocalStatusFilter(_ status: SpaceStatus) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .equal
        filter.value = status.rawValue.protobufValue
        filter.relationKey = BundledRelationKey.spaceLocalStatus.rawValue
        
        return filter
    }
    
    public static func templateScheme(include: Bool) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = include ? .equal : .notEqual
        filter.relationKey = "\(BundledRelationKey.type.rawValue).\(BundledRelationKey.uniqueKey.rawValue)"
        filter.value = ObjectTypeUniqueKey.template.value.protobufValue

        return filter
    }
    
    public static func isHiddenDiscovery(_ isHidden: Bool) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = isHidden ? .equal : .notEqual
        filter.value = true
        
        filter.relationKey = BundledRelationKey.isHiddenDiscovery.rawValue
        
        return filter
    }
    
    public static func notHiddenFilters(isArchive: Bool = false, hideHiddenDescoveryFiles: Bool = true) -> [DataviewFilter] {
        .builder {
            SearchHelper.isHidden(false)
            if hideHiddenDescoveryFiles { SearchHelper.isHiddenDiscovery(false) }
            SearchHelper.isDeletedFilter(isDeleted: false)
            SearchHelper.isArchivedFilter(isArchived: isArchive)
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
        
        filter.relationKey = BundledRelationKey.setOf.rawValue
        
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
    
    private static func emptyLinks() -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .empty
        filter.relationKey = BundledRelationKey.links.rawValue
        
        return filter
    }
    
    private static func emptyBacklinks() -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .empty
        filter.relationKey = BundledRelationKey.backlinks.rawValue
        
        return filter
    }
}
