import ProtobufMessages
import Combine
import BlocksModels
import AnytypeCore

protocol SearchServiceProtocol: AnyObject {
    func search(text: String) -> [ObjectDetails]?
    func searchObjectTypes(
        text: String,
        filteringTypeId: String?,
        shouldIncludeSets: Bool,
        shouldIncludeBookmark: Bool
    ) -> [ObjectDetails]?
    func searchMarketplaceObjectTypes(text: String, excludedIds: [String]) -> [ObjectDetails]?
    func searchFiles(text: String, excludedFileIds: [String]) -> [ObjectDetails]?
    func searchObjects(text: String, excludedObjectIds: [String], limitedTypeIds: [String]) -> [ObjectDetails]?
    func searchTemplates(for type: ObjectTypeId) -> [ObjectDetails]?
    func searchObjects(
        text: String,
        excludedObjectIds: [String],
        excludedTypeIds: [String],
        sortRelationKey: BundledRelationKey?
    ) -> [ObjectDetails]?
    func searchRelationOptions(text: String, relationKey: String, excludedObjectIds: [String]) -> [RelationOption]?
    func searchRelationOptions(optionIds: [String]) -> [RelationOption]?
    func searchRelations(text: String, excludedIds: [String]) -> [RelationDetails]?
    func searchMarketplaceRelations(text: String, excludedIds: [String]) -> [RelationDetails]?
}

final class SearchService: ObservableObject, SearchServiceProtocol {
    
    private enum Constants {
        static let defaultLimit = 100
    }
    
    private let accountManager: AccountManager
    private let objectTypeProvider: ObjectTypeProviderProtocol
    
    init(accountManager: AccountManager, objectTypeProvider: ObjectTypeProviderProtocol) {
        self.accountManager = accountManager
        self.objectTypeProvider = objectTypeProvider
    }
    
    // MARK: - SearchServiceProtocol
    
    func search(text: String) -> [ObjectDetails]? {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastOpenedDate,
            type: .desc
        )
        
        let filters = buildFilters(
            isArchived: false,
            excludedTypeIds: objectTypeProvider.notVisibleTypeIds()
        )
        
        return search(filters: filters, sorts: [sort], fullText: text, limit: Constants.defaultLimit)
    }
    
    func searchObjectTypes(
        text: String,
        filteringTypeId: String? = nil,
        shouldIncludeSets: Bool,
        shouldIncludeBookmark: Bool
    ) -> [ObjectDetails]? {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.name,
            type: .asc
        )
        
        var excludedTypeIds: [String] = [
            filteringTypeId,
            shouldIncludeSets ? nil : ObjectTypeId.bundled(.set).rawValue,
            shouldIncludeBookmark ? nil : ObjectTypeId.bundled(.bookmark).rawValue
        ].compactMap { $0 }
        
        excludedTypeIds.append(contentsOf: objectTypeProvider.notVisibleTypeIds())
        
        var filters = buildFilters(isArchived: false)
        filters.append(contentsOf: [
            SearchHelper.typeFilter(typeIds: [ObjectTypeId.bundled(.objectType).rawValue]),
            SearchHelper.excludedIdsFilter(excludedTypeIds)
        ])
        
        let result = search(filters: filters, sorts: [sort], fullText: text)

        return result?.reordered(
            by: [
                ObjectTypeId.bundled(.page).rawValue,
                ObjectTypeId.bundled(.note).rawValue,
                ObjectTypeId.bundled(.task).rawValue,
                ObjectTypeId.bundled(.set).rawValue
            ]
        ) { $0.id }
    }
    
    func searchMarketplaceObjectTypes(text: String, excludedIds: [String]) -> [ObjectDetails]? {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.name,
            type: .asc
        )
        
        let filters = [
            SearchHelper.workspaceId(MarketplaceId.anytypeMarketplace.rawValue),
            SearchHelper.typeFilter(typeIds: [ ObjectTypeId.bundled(.systemObjectType).rawValue]),
            SearchHelper.excludedIdsFilter([ObjectTypeId.bundled(.systemBookmark).rawValue] + excludedIds),
            SearchHelper.smartblockTypesFilter(types: [.page]),
        ]
        
        let result = search(filters: filters, sorts: [sort], fullText: text)
        return result
    }
    
    func searchFiles(text: String, excludedFileIds: [String]) -> [ObjectDetails]? {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.name,
            type: .asc
        )
        
        let filters = [
            SearchHelper.notHiddenFilter(),
            SearchHelper.isDeletedFilter(isDeleted: false),
            SearchHelper.layoutFilter(layouts: [DetailsLayout.fileLayout, DetailsLayout.imageLayout]),
            SearchHelper.excludedIdsFilter(excludedFileIds),
            SearchHelper.workspaceId(accountManager.account.info.accountSpaceId),
        ]
        
        return search(filters: filters, sorts: [sort], fullText: text, limit: Constants.defaultLimit)
    }
    
    func searchObjects(text: String, excludedObjectIds: [String], limitedTypeIds: [String]) -> [ObjectDetails]? {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastOpenedDate,
            type: .desc
        )
        
        var filters = limitedTypeIds.isNotEmpty
            ? buildFilters(isArchived: false, typeIds: limitedTypeIds)
            : buildFilters(isArchived: false, excludedTypeIds: objectTypeProvider.notVisibleTypeIds())
                
        filters.append(SearchHelper.excludedIdsFilter(excludedObjectIds))
        
        return search(filters: filters, sorts: [sort], fullText: text)
    }

    func searchTemplates(for type: ObjectTypeId) -> [ObjectDetails]? {
        return search(filters: SearchHelper.templatesFilters(type: type))
    }
	
    func searchObjects(
        text: String,
        excludedObjectIds: [String],
        excludedTypeIds: [String],
        sortRelationKey: BundledRelationKey?
    ) -> [ObjectDetails]? {
        let sort = SearchHelper.sort(
            relation: sortRelationKey ?? .lastOpenedDate,
            type: .desc
        )
        
        var filters = buildFilters(
            isArchived: false,
            excludedTypeIds: objectTypeProvider.notVisibleTypeIds() + excludedTypeIds
        )
        filters.append(SearchHelper.excludedIdsFilter(excludedObjectIds))
        
        return search(filters: filters, sorts: [sort], fullText: text, limit: Constants.defaultLimit)
    }

    func searchRelationOptions(text: String, relationKey: String, excludedObjectIds: [String]) -> [RelationOption]? {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.name,
            type: .asc
        )

        var filters = buildFilters(
            isArchived: false,
            typeIds: [ObjectTypeId.bundled(.relationOption).rawValue]
        )
        filters.append(SearchHelper.relationKey(relationKey))
        filters.append(SearchHelper.excludedIdsFilter(excludedObjectIds))
        
        let details = search(filters: filters, sorts: [sort], fullText: text, limit: 0)
        return details?.map { RelationOption(details: $0) }
    }

    func searchRelationOptions(optionIds: [String]) -> [RelationOption]? {
        var filters = buildFilters(
            isArchived: false,
            typeIds: [ObjectTypeId.bundled(.relationOption).rawValue]
        )
        filters.append(SearchHelper.supportedIdsFilter(optionIds))

        let details = search(filters: filters, sorts: [], fullText: "")
        return details?.map { RelationOption(details: $0) }
    }
    
    func searchRelations(text: String, excludedIds: [String]) -> [RelationDetails]? {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.name,
            type: .asc
        )
        var filters = buildFilters(
            isArchived: false,
            typeIds: [ObjectTypeId.bundled(.relation).rawValue]
        )
        filters.append(SearchHelper.excludedRelationKeys(BundledRelationKey.systemKeys.map(\.rawValue)))
        filters.append(SearchHelper.excludedIdsFilter(excludedIds))
        let details = search(filters: filters, sorts: [sort], fullText: text)
        return details?.map { RelationDetails(objectDetails: $0) }
    }
    
    func searchMarketplaceRelations(text: String, excludedIds: [String]) -> [RelationDetails]? {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.name,
            type: .asc
        )
        var filters = buildFilters(
            isArchived: false,
            typeIds: [ObjectTypeId.bundled(.systemRelation).rawValue],
            workspaceId: MarketplaceId.anytypeMarketplace.rawValue
        )
        filters.append(SearchHelper.excludedRelationKeys(BundledRelationKey.systemKeys.map(\.rawValue)))
        filters.append(SearchHelper.excludedIdsFilter(excludedIds))
        let details = search(filters: filters, sorts: [sort], fullText: text)
        return details?.map { RelationDetails(objectDetails: $0) }
    }
}

private extension SearchService {
    
    func search(
        filters: [DataviewFilter] = [],
        sorts: [DataviewSort] = [],
        fullText: String = "",
        limit: Int = 0
    ) -> [ObjectDetails]? {
        
        guard let response = Anytype_Rpc.Object.Search.Service.invoke(
            filters: filters,
            sorts: sorts,
            fullText: fullText,
            offset: 0,
            limit: Int32(limit),
            objectTypeFilter: [],
            keys: []
        ).getValue(domain: .searchService) else { return nil }
       
        return response.records.asDetais
    }

    private func buildFilters(isArchived: Bool, workspaceId: String? = nil) -> [DataviewFilter] {
        [
            SearchHelper.notHiddenFilter(),
            SearchHelper.isArchivedFilter(isArchived: isArchived),
             SearchHelper.workspaceId(workspaceId ?? accountManager.account.info.accountSpaceId),
        ]
    }
    
    private func buildFilters(isArchived: Bool, typeIds: [String], workspaceId: String? = nil) -> [DataviewFilter] {
        var filters = buildFilters(isArchived: isArchived, workspaceId: workspaceId)
        filters.append(SearchHelper.typeFilter(typeIds: typeIds))
        return filters
    }
    
    private func buildFilters(isArchived: Bool, excludedTypeIds: [String]) -> [DataviewFilter] {
        var filters = buildFilters(isArchived: isArchived)
        filters.append(SearchHelper.excludedTypeFilter(excludedTypeIds))
        return filters
    }
}
