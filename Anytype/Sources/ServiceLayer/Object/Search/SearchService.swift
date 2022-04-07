import ProtobufMessages
import Combine
import BlocksModels

protocol SearchServiceProtocol {
    func search(text: String) -> [ObjectDetails]?
    func searchObjectTypes(text: String, filteringTypeUrl: String?) -> [ObjectDetails]?
    func searchFiles(text: String, excludedFileIds: [String]) -> [ObjectDetails]?
    func searchObjects(text: String, excludedObjectIds: [String], limitedTypeUrls: [String]) -> [ObjectDetails]?
}

final class SearchService: ObservableObject, SearchServiceProtocol {
    
    // MARK: - Private variables
    
    private var subscriptions = [AnyCancellable]()
    
    // MARK: - SearchServiceProtocol
    
    func search(text: String) -> [ObjectDetails]? {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastOpenedDate,
            type: .desc
        )
        
        let filters = buildFilters(
            isArchived: false,
            typeUrls: ObjectTypeProvider.supportedTypeUrls
        )
        
        return makeRequest(filters: filters, sorts: [sort], fullText: text)
    }
    
    func searchObjectTypes(text: String, filteringTypeUrl: String? = nil) -> [ObjectDetails]? {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.name,
            type: .asc
        )
        var filters = [
            SearchHelper.isArchivedFilter(isArchived: false),
            SearchHelper.supportedObjectTypeUrlsFilter(
                ObjectTypeProvider.supportedTypeUrls
            ),
            SearchHelper.excludedObjectTypeUrlFilter(ObjectTemplateType.BundledType.set.rawValue)
        ]
        filteringTypeUrl.map { filters.append(SearchHelper.excludedObjectTypeUrlFilter($0)) }


        let result = makeRequest(filters: filters, sorts: [sort], fullText: text)
        
        return result?.reordered(
            by: [
                ObjectTemplateType.BundledType.page.rawValue,
                ObjectTemplateType.BundledType.note.rawValue,
                ObjectTemplateType.BundledType.task.rawValue
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
        
        return makeRequest(filters: filters, sorts: [sort], fullText: text)
    }
    
    func searchObjects(text: String, excludedObjectIds: [String], limitedTypeUrls: [String]) -> [ObjectDetails]? {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastOpenedDate,
            type: .desc
        )
        
        let typeUrls: [String] = limitedTypeUrls.isNotEmpty ? limitedTypeUrls : ObjectTypeProvider.supportedTypeUrls
        var filters = buildFilters(isArchived: false, typeUrls: typeUrls)
        filters.append(SearchHelper.excludedIdsFilter(excludedObjectIds))
        
        return makeRequest(filters: filters, sorts: [sort], fullText: text)
    }
    
}

private extension SearchService {
    
    func makeRequest(
        filters: [DataviewFilter],
        sorts: [DataviewSort],
        fullText: String
    ) -> [ObjectDetails]? {
        guard let response = Anytype_Rpc.Object.Search.Service.invoke(
            filters: filters,
            sorts: sorts,
            fullText: fullText,
            offset: 0,
            limit: 100,
            objectTypeFilter: [],
            keys: []
        ).getValue(domain: .searchService) else { return nil }
            
        let details: [ObjectDetails] = response.records.compactMap { search in
            let idValue = search.fields["id"]
            let idString = idValue?.unwrapedListValue.stringValue
            
            guard let id = idString, id.isNotEmpty else { return nil }
            
            return ObjectDetails(id: id, values: search.fields)
        }
            
        return details
    }
    
    func buildFilters(isArchived: Bool, typeUrls: [String]) -> [DataviewFilter] {
        [
            SearchHelper.notHiddenFilter(),
            SearchHelper.isArchivedFilter(isArchived: isArchived),
            SearchHelper.typeFilter(typeUrls: typeUrls)
        ]
    }
    
}
