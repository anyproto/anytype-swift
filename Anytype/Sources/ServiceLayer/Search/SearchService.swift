import ProtobufMessages
import Combine
import BlocksModels

protocol SearchServiceProtocol {
    func search(text: String, completion: @escaping ([DetailsDataProtocol]) -> ())
    func searchArchivedPages(completion: @escaping ([DetailsDataProtocol]) -> ())
    func searchRecentPages(completion: @escaping ([DetailsDataProtocol]) -> ())
    func searchSets(completion: @escaping ([DetailsDataProtocol]) -> ())
}

final class SearchService: SearchServiceProtocol {
    private var subscriptions = [AnyCancellable]()
    
    func search(text: String, completion: @escaping ([DetailsDataProtocol]) -> ()) {
        let sort = SearchHelper.sort(
            relation: DetailsKind.lastOpenedDate,
            type: .desc
        )
        
        let filters = [
            SearchHelper.isArchivedFilter(isArchived: false),
            SearchHelper.notHiddenFilter(),
            SearchHelper.typeFilter(typeUrls: ObjectTypeProvider.supportedTypeUrls)
        ]
        
        makeRequest(
            filters: filters,
            sorts: [sort],
            fullText: text,
            offset: 0,
            limit: 100,
            objectTypeFilter: [],
            keys: [],
            completion: completion
        )
    }
    
    func searchArchivedPages(completion: @escaping ([DetailsDataProtocol]) -> ()) {
        let sort = SearchHelper.sort(
            relation: DetailsKind.lastModifiedDate,
            type: .desc
        )
        
        let filters = [
            SearchHelper.isArchivedFilter(isArchived: true),
            SearchHelper.notHiddenFilter(),
            SearchHelper.typeFilter(typeUrls: ObjectTypeProvider.supportedTypeUrls)
        ]
        
        makeRequest(
            filters: filters,
            sorts: [sort],
            fullText: "",
            offset: 0,
            limit: 100,
            objectTypeFilter: [],
            keys: [],
            completion: completion
        )
    }
    
    func searchRecentPages(completion: @escaping ([DetailsDataProtocol]) -> ()) {
        let sort = SearchHelper.sort(
            relation: DetailsKind.lastOpenedDate,
            type: .desc
        )
        let filters = [
            SearchHelper.notHiddenFilter(),
            SearchHelper.typeFilter(typeUrls: ObjectTypeProvider.supportedTypeUrls)
        ]
        
        makeRequest(
            filters: filters,
            sorts: [sort],
            fullText: "",
            offset: 0,
            limit: 30,
            objectTypeFilter: [],
            keys: [],
            completion: completion
        )
    }
    
    func searchSets(completion: @escaping ([DetailsDataProtocol]) -> ()) {
        let sort = SearchHelper.sort(
            relation: DetailsKind.lastOpenedDate,
            type: .desc
        )
        let filters = [
            SearchHelper.isArchivedFilter(isArchived: false),
            SearchHelper.notHiddenFilter(),
            SearchHelper.typeFilter(typeUrls: ObjectTypeProvider.supportedTypeUrls)
        ]
        
        makeRequest(
            filters: filters,
            sorts: [sort],
            fullText: "",
            offset: 0,
            limit: 100,
            objectTypeFilter: [],
            keys: [],
            completion: completion
        )
    }
    
    private func makeRequest(
        filters: [Anytype_Model_Block.Content.Dataview.Filter],
        sorts: [Anytype_Model_Block.Content.Dataview.Sort],
        fullText: String,
        offset: Int32,
        limit: Int32,
        objectTypeFilter: [String],
        keys: [String],
        completion: @escaping ([DetailsDataProtocol]) -> ()
    ) {
        Anytype_Rpc.Object.Search.Service.invoke(
            filters: filters,
            sorts: sorts,
            fullText: fullText,
            offset: offset,
            limit: limit,
            objectTypeFilter: objectTypeFilter,
            keys: keys,
            queue: .global()
        )
        .receiveOnMain()
        .sinkWithDefaultCompletion("Search") { response in
            
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
            
            completion(details)
        }
        .store(in: &subscriptions)
    }
}
