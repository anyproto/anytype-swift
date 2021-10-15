import ProtobufMessages
import Combine
import BlocksModels

protocol SearchServiceProtocol {
    func search(text: String) -> [DetailsDataProtocol]?
    func searchArchivedPages() -> [DetailsDataProtocol]?
    func searchHistoryPages() -> [DetailsDataProtocol]?
    func searchSets() -> [DetailsDataProtocol]?
}

final class SearchService: ObservableObject, SearchServiceProtocol {
    private var subscriptions = [AnyCancellable]()
    
    func search(text: String) -> [DetailsDataProtocol]? {
        let sort = SearchHelper.sort(
            relation: DetailsKind.lastOpenedDate,
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
    
    func searchArchivedPages() -> [DetailsDataProtocol]? {
        let sort = SearchHelper.sort(
            relation: DetailsKind.lastModifiedDate,
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
    
    func searchHistoryPages() -> [DetailsDataProtocol]? {
        let sort = SearchHelper.sort(
            relation: DetailsKind.lastModifiedDate,
            type: .desc
        )
        let filters = [
            SearchHelper.notHiddenFilter(),
            SearchHelper.isArchivedFilter(isArchived: false),
            SearchHelper.typeFilter(typeUrls: [ObjectTypeProvider.pageObjectURL])
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
    
    func searchSets() -> [DetailsDataProtocol]? {
        let sort = SearchHelper.sort(
            relation: DetailsKind.lastOpenedDate,
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
    ) -> [DetailsDataProtocol]? {
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
            
        let details: [DetailsData] = response.records.compactMap {
            let rawDetails = DetailsEntryConverter.convert(details: $0.fields)
            return DetailsData(rawDetails: rawDetails)
        }
        
        details.forEach { detail in
            DetailsContainer.shared.add(
                model: LegacyDetailsModel(detailsData: detail),
                id: detail.blockId
            )
        }
            
        return details
    }
}
