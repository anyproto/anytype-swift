import ProtobufMessages
import Combine
import BlocksModels

protocol SearchServiceProtocol {
    func search(text: String) -> [ObjectDetails]?
    func searchArchivedPages() -> [ObjectDetails]?
    func searchHistoryPages() -> [ObjectDetails]?
    func searchSets() -> [ObjectDetails]?
}

final class SearchService: ObservableObject, SearchServiceProtocol {
    private var subscriptions = [AnyCancellable]()
    
    func search(text: String) -> [ObjectDetails]? {
        let sort = SearchHelper.sort(
            relation: RelationKey.lastOpenedDate,
            type: .desc
        )
        
        let filters = [
            SearchHelper.isArchivedFilter(isArchived: false),
            SearchHelper.notHiddenFilter(),
            SearchHelper.typeFilter(typeUrls: ObjectTypeProvider.supportedTypeUrls)
        ]
        
        return makeRequest(
            filters: filters, sorts: [sort], fullText: text,
            offset: 0, limit: 100, objectTypeFilter: [], keys: []
        )
    }
    
    func searchArchivedPages() -> [ObjectDetails]? {
        let sort = SearchHelper.sort(
            relation: RelationKey.lastModifiedDate,
            type: .desc
        )
        
        let filters = [
            SearchHelper.isArchivedFilter(isArchived: true),
            SearchHelper.notHiddenFilter(),
            SearchHelper.typeFilter(typeUrls: ObjectTypeProvider.supportedTypeUrls)
        ]
        
        return makeRequest(
            filters: filters,
            sorts: [sort],
            fullText: "",
            offset: 0,
            limit: 100,
            objectTypeFilter: [],
            keys: []
        )
    }
    
    func searchHistoryPages() -> [ObjectDetails]? {
        let sort = SearchHelper.sort(
            relation: RelationKey.lastModifiedDate,
            type: .desc
        )
        let searchTypes: [ObjectTemplateType] = [.note, .page]
        let filters = [
            SearchHelper.notHiddenFilter(),
            SearchHelper.isArchivedFilter(isArchived: false),
            SearchHelper.typeFilter(typeUrls: searchTypes.map { $0.rawValue })
        ]
        
        return makeRequest(
            filters: filters,
            sorts: [sort],
            fullText: "",
            offset: 0,
            limit: 30,
            objectTypeFilter: [],
            keys: []
        )
    }
    
    func searchSets() -> [ObjectDetails]? {
        let sort = SearchHelper.sort(
            relation: RelationKey.lastOpenedDate,
            type: .desc
        )
        let filters = [
            SearchHelper.isArchivedFilter(isArchived: false),
            SearchHelper.notHiddenFilter(),
            SearchHelper.typeFilter(typeUrls: ObjectTypeProvider.supportedTypeUrls)
        ]
        
        return makeRequest(
            filters: filters,
            sorts: [sort],
            fullText: "",
            offset: 0,
            limit: 100,
            objectTypeFilter: [],
            keys: []
        )
    }
    
    private func makeRequest(
        filters: [Anytype_Model_Block.Content.Dataview.Filter],
        sorts: [Anytype_Model_Block.Content.Dataview.Sort],
        fullText: String,
        offset: Int32,
        limit: Int32,
        objectTypeFilter: [String],
        keys: [String]
    ) -> [ObjectDetails]? {
        guard let response = Anytype_Rpc.Object.Search.Service.invoke(
            filters: filters,
            sorts: sorts,
            fullText: fullText,
            offset: offset,
            limit: limit,
            objectTypeFilter: objectTypeFilter,
            keys: keys,
            ignoreWorkspace: false
        ).getValue() else { return nil }
            
        let details: [ObjectDetails] = response.records.compactMap { search in
            let idValue = search.fields["id"]
            let idString = idValue?.unwrapedListValue.stringValue
            
            guard
                let id = idString,
                id.isNotEmpty
            else { return nil }
            
            return ObjectDetails(
                id: id,
                values: search.fields
            )
        }
            
        return details
    }
}
