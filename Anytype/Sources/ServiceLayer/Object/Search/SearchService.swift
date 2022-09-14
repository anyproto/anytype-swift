import ProtobufMessages
import Combine
import BlocksModels
import AnytypeCore

protocol SearchServiceProtocol {
    func search(text: String) -> [ObjectDetails]?
    func searchObjectTypes(text: String, filteringTypeId: String?, shouldIncludeSets: Bool) -> [ObjectDetails]?
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
}

final class SearchService: ObservableObject, SearchServiceProtocol {
    
    private let searchCommonService: SearchCommonServiceProtocol
    
    init(searchCommonService: SearchCommonServiceProtocol) {
        self.searchCommonService = searchCommonService
    }
    
    // MARK: - SearchServiceProtocol
    
    func search(text: String) -> [ObjectDetails]? {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastOpenedDate,
            type: .desc
        )
        
        let filters = buildFilters(
            isArchived: false,
            typeIds: ObjectTypeProvider.shared.supportedTypeIds
        )
        
        return searchCommonService.search(filters: filters, sorts: [sort], fullText: text)
    }
    
    func searchObjectTypes(
        text: String,
        filteringTypeId: String? = nil,
        shouldIncludeSets: Bool
    ) -> [ObjectDetails]? {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.name,
            type: .asc
        )
        var filters = [
            SearchHelper.isArchivedFilter(isArchived: false),
            SearchHelper.typeFilter(typeIds: [ObjectTypeId.bundled(.objectType).rawValue]),
            SearchHelper.supportedIdsFilter(
                ObjectTypeProvider.shared.supportedTypeIds
            ),
            shouldIncludeSets ? nil : SearchHelper.excludedIdFilter(ObjectTypeId.bundled(.set).rawValue)
        ].compactMap { $0 }
        if FeatureFlags.bookmarksFlow {
            filters.append(SearchHelper.excludedIdFilter(ObjectTypeId.bundled(.bookmark).rawValue))
        }
        filteringTypeId.map { filters.append(SearchHelper.excludedIdFilter($0)) }

        let result = searchCommonService.search(filters: filters, sorts: [sort], fullText: text, limit: 0)
        return result?.reordered(
            by: [
                ObjectTypeId.bundled(.page).rawValue,
                ObjectTypeId.bundled(.note).rawValue,
                ObjectTypeId.bundled(.task).rawValue,
                ObjectTypeId.bundled(.set).rawValue
            ]
        ) { $0.id }
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
            SearchHelper.excludedIdsFilter(excludedFileIds)
        ]
        
        return searchCommonService.search(filters: filters, sorts: [sort], fullText: text)
    }
    
    func searchObjects(text: String, excludedObjectIds: [String], limitedTypeIds: [String]) -> [ObjectDetails]? {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastOpenedDate,
            type: .desc
        )
        
        let typeIds: [String] = limitedTypeIds.isNotEmpty ? limitedTypeIds : ObjectTypeProvider.shared.supportedTypeIds
        var filters = buildFilters(isArchived: false, typeIds: typeIds)
        filters.append(SearchHelper.excludedIdsFilter(excludedObjectIds))
        
        return searchCommonService.search(filters: filters, sorts: [sort], fullText: text)
    }

    func searchTemplates(for type: ObjectTypeId) -> [ObjectDetails]? {
        return searchCommonService.search(filters: SearchHelper.templatesFilters(type: type))
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
            typeIds: ObjectTypeProvider.shared.supportedTypeIds
        )
        filters.append(SearchHelper.excludedTypeFilter(excludedTypeIds))
        filters.append(SearchHelper.excludedIdsFilter(excludedObjectIds))
        
        return searchCommonService.search(filters: filters, sorts: [sort], fullText: text)
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
        filters.append(SearchHelper.relationOptionText(text))

        let details = searchCommonService.search(filters: filters, sorts: [sort], fullText: "")
        return details?.map { RelationOption(details: $0) }
    }

    func searchRelationOptions(optionIds: [String]) -> [RelationOption]? {
        var filters = buildFilters(
            isArchived: false,
            typeIds: [ObjectTypeId.bundled(.relationOption).rawValue]
        )
        filters.append(SearchHelper.supportedIdsFilter(optionIds))

        let details = searchCommonService.search(filters: filters, sorts: [], fullText: "")
        return details?.map { RelationOption(details: $0) }
    }
}

private extension SearchService {

    func buildFilters(isArchived: Bool, typeIds: [String]) -> [DataviewFilter] {
        [
            SearchHelper.notHiddenFilter(),
            SearchHelper.isArchivedFilter(isArchived: isArchived),
            SearchHelper.typeFilter(typeIds: typeIds)
        ]
    }
    
}
