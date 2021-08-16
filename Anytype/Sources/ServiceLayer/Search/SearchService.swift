import ProtobufMessages
import Combine
import BlocksModels

protocol SearchServiceProtocol {
    func search(text: String, completion: @escaping ([SearchResult]) -> ())
    func searchArchivedPages(completion: @escaping ([SearchResult]) -> ())
    func searchRecentPages(completion: @escaping ([SearchResult]) -> ())
    func searchInboxPages(completion: @escaping ([SearchResult]) -> ())
    func searchSets(completion: @escaping ([SearchResult]) -> ())
}

final class SearchService {
    private var subscriptions = [AnyCancellable]()
    
    func search(text: String, completion: @escaping ([SearchResult]) -> ()) {
        let sort = MiddlewareBuilder.sort(
            relation: DetailsKind.lastModifiedDate,
            type: .desc
        )
        
        let filters = [
            MiddlewareBuilder.isArchivedFilter(isArchived: false),
            MiddlewareBuilder.notHiddenFilter()
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
    
    func searchArchivedPages(completion: @escaping ([SearchResult]) -> ()) {
        let sort = MiddlewareBuilder.sort(
            relation: DetailsKind.lastModifiedDate,
            type: .desc
        )
        
        let filters = [
            MiddlewareBuilder.isArchivedFilter(isArchived: true),
            MiddlewareBuilder.notHiddenFilter()
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
    
    func searchRecentPages(completion: @escaping ([SearchResult]) -> ()) {
        let sort = MiddlewareBuilder.sort(
            relation: DetailsKind.lastOpenedDate,
            type: .desc
        )
        let filters = [
            MiddlewareBuilder.objectTypeFilter(types: [.set, .page]),
            MiddlewareBuilder.notHiddenFilter()
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
    
    func searchInboxPages(completion: @escaping ([SearchResult]) -> ()) {
        let sort = MiddlewareBuilder.sort(
            relation: DetailsKind.lastOpenedDate,
            type: .desc
        )
        let filters = [
            MiddlewareBuilder.isArchivedFilter(isArchived: false),
            MiddlewareBuilder.objectTypeFilter(type: .page),
            MiddlewareBuilder.notHiddenFilter()
        ]
        
        makeRequest(
            filters: filters,
            sorts: [sort],
            fullText: "",
            offset: 0,
            limit: 50,
            objectTypeFilter: [],
            keys: [],
            completion: completion
        )
    }
    
    func searchSets(completion: @escaping ([SearchResult]) -> ()) {
        let sort = MiddlewareBuilder.sort(
            relation: DetailsKind.lastOpenedDate,
            type: .desc
        )
        let filters = [
            MiddlewareBuilder.isArchivedFilter(isArchived: false),
            MiddlewareBuilder.objectTypeFilter(type: .set),
            MiddlewareBuilder.notHiddenFilter()
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
        completion: @escaping ([SearchResult]) -> ()
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
            completion(
                response.records.compactMap { SearchResult(fields: $0.fields) }
            )
        }
        .store(in: &subscriptions)
    }
}
