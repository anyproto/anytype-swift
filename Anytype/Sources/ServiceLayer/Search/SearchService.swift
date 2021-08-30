import ProtobufMessages
import Combine
import BlocksModels

protocol SearchServiceProtocol {
    func search(text: String, completion: @escaping ([SearchResult]) -> ())
    func searchArchivedPages(completion: @escaping ([SearchResult]) -> ())
    func searchRecentPages(completion: @escaping ([SearchResult]) -> ())
    func searchInboxPages(completion: @escaping ([SearchResult]) -> ())
    func searchSets(completion: @escaping ([SearchResult]) -> ())
    func searchMentions(text: String, completion: @escaping ([SearchResult]) -> ())
}

final class SearchService: SearchServiceProtocol {
    private var subscriptions = [AnyCancellable]()
    
    func search(text: String, completion: @escaping ([SearchResult]) -> ()) {
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
    
    func searchArchivedPages(completion: @escaping ([SearchResult]) -> ()) {
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
    
    func searchRecentPages(completion: @escaping ([SearchResult]) -> ()) {
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
    
    func searchInboxPages(completion: @escaping ([SearchResult]) -> ()) {
        let sort = SearchHelper.sort(
            relation: DetailsKind.lastModifiedDate,
            type: .desc
        )
        let filters = [
            SearchHelper.isArchivedFilter(isArchived: false),
            SearchHelper.notHiddenFilter(),
            SearchHelper.typeFilter(typeUrls: [ObjectTypeProvider.pageObjectURL])
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
    
    func searchMentions(text: String, completion: @escaping ([SearchResult]) -> ()) {
        let sort = SearchHelper.sort(relation: .name, type: .asc)
        
        let filter = SearchHelper.notHiddenFilter()
        
        let objectTypes = ObjectTypeProvider.supportedTypeUrls
        
        let keys = [DetailsKind.id,
                    DetailsKind.name,
                    DetailsKind.description,
                    DetailsKind.iconEmoji,
                    DetailsKind.iconImage,
                    DetailsKind.type,
                    DetailsKind.layout,
                    DetailsKind.isHidden,
                    DetailsKind.isArchived,
                    DetailsKind.done]
            .map(\.rawValue)
        
        makeRequest(
            filters: [filter],
            sorts: [sort],
            fullText: text,
            offset: 0,
            limit: 0,
            objectTypeFilter: objectTypes,
            keys: keys,
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
