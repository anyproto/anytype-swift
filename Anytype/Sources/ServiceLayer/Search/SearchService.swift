import ProtobufMessages

final class SearchService {
    func searchForArchivedPages(completion: @escaping ([SearchResult]) -> ()) {
        var sort = Anytype_Model_Block.Content.Dataview.Sort()
        sort.relationKey = Relations.lastModifiedDate
        sort.type = .desc
        
        var filter = Anytype_Model_Block.Content.Dataview.Filter()
        filter.condition = .equal
        filter.value = true
        filter.relationKey = Relations.isArchived
        filter.operator = .and
        
        DispatchQueue.global().async {
            let result = Anytype_Rpc.Object.Search.Service.invoke(
                filters: [filter],
                sorts: [sort],
                fullText: "",
                offset: 0,
                limit: 100,
                objectTypeFilter: [],
                keys: []
            )
            
            guard let response = try? result.get() else {
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }
            
            let searchResults = response.records.compactMap {
                SearchResult(fields: $0.fields)
            }
            DispatchQueue.main.async {
                completion(searchResults)
            }
        }

    }
}
