import ProtobufMessages
import Combine
import BlocksModels
import AnytypeCore

protocol SearchServiceProtocol {
    func search(text: String) -> [ObjectDetails]?
    func searchObjectTypes(text: String, filteringTypeUrl: String?) -> [ObjectDetails]?
    func searchFiles(text: String, excludedFileIds: [String]) -> [ObjectDetails]?
    func searchObjects(text: String, excludedObjectIds: [String], limitedTypeUrls: [String]) -> [ObjectDetails]?
    func searchTemplates(for type: ObjectTypeUrl) -> [ObjectDetails]?
    func searchObjects(
        text: String,
        excludedObjectIds: [String],
        excludedTypeUrls: [String],
        sortRelationKey: BundledRelationKey?
    ) -> [ObjectDetails]?
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
            typeUrls: ObjectTypeProvider.shared.supportedTypeUrls
        )
        
        return searchCommonService.search(filters: filters, sorts: [sort], fullText: text)
    }
    
    func searchObjectTypes(text: String, filteringTypeUrl: String? = nil) -> [ObjectDetails]? {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.name,
            type: .asc
        )
        var filters = [
            SearchHelper.isArchivedFilter(isArchived: false),
            SearchHelper.typeFilter(typeUrls: [ObjectTypeUrl.bundled(.objectType).rawValue]),
            SearchHelper.supportedObjectTypeUrlsFilter(
                ObjectTypeProvider.shared.supportedTypeUrls
            ),
            SearchHelper.excludedObjectTypeUrlFilter(ObjectTypeUrl.bundled(.set).rawValue)
        ]
        if FeatureFlags.bookmarksFlow {
            filters.append(SearchHelper.excludedObjectTypeUrlFilter(ObjectTypeUrl.bundled(.bookmark).rawValue))
        }
        filteringTypeUrl.map { filters.append(SearchHelper.excludedObjectTypeUrlFilter($0)) }

        let result = searchCommonService.search(filters: filters, sorts: [sort], fullText: text, limit: 0)
        return result?.reordered(
            by: [
                ObjectTypeUrl.bundled(.page).rawValue,
                ObjectTypeUrl.bundled(.note).rawValue,
                ObjectTypeUrl.bundled(.task).rawValue
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
    
    func searchObjects(text: String, excludedObjectIds: [String], limitedTypeUrls: [String]) -> [ObjectDetails]? {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastOpenedDate,
            type: .desc
        )
        
        let typeUrls: [String] = limitedTypeUrls.isNotEmpty ? limitedTypeUrls : ObjectTypeProvider.shared.supportedTypeUrls
        var filters = buildFilters(isArchived: false, typeUrls: typeUrls)
        filters.append(SearchHelper.excludedIdsFilter(excludedObjectIds))
        
        return searchCommonService.search(filters: filters, sorts: [sort], fullText: text)
    }

    func searchTemplates(for type: ObjectTypeUrl) -> [ObjectDetails]? {
        return searchCommonService.search(filters: SearchHelper.templatesFilters(type: type))
    }
	
    func searchObjects(
        text: String,
        excludedObjectIds: [String],
        excludedTypeUrls: [String],
        sortRelationKey: BundledRelationKey?
    ) -> [ObjectDetails]? {
        let sort = SearchHelper.sort(
            relation: sortRelationKey ?? .lastOpenedDate,
            type: .desc
        )
        
        var filters = buildFilters(
            isArchived: false,
            typeUrls: ObjectTypeProvider.shared.supportedTypeUrls
        )
        filters.append(SearchHelper.excludedTypeFilter(excludedTypeUrls))
        filters.append(SearchHelper.excludedIdsFilter(excludedObjectIds))
        
        return searchCommonService.search(filters: filters, sorts: [sort], fullText: text)
    }
}

private extension SearchService {
        
    func buildFilters(isArchived: Bool, typeUrls: [String]) -> [DataviewFilter] {
        [
            SearchHelper.notHiddenFilter(),
            SearchHelper.isArchivedFilter(isArchived: isArchived),
            SearchHelper.typeFilter(typeUrls: typeUrls)
        ]
    }
    
}
