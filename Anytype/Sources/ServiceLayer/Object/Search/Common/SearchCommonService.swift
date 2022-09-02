import Foundation
import BlocksModels
import ProtobufMessages

final class SearchCommonService {
    
    init() {}
    
    func search(
        filters: [DataviewFilter] = [],
        sorts: [DataviewSort] = [],
        fullText: String = "",
        limit: Int32 = 100
    ) -> [ObjectDetails]? {
        
        guard let response = Anytype_Rpc.Object.Search.Service.invoke(
            filters: filters,
            sorts: sorts,
            fullText: fullText,
            offset: 0,
            limit: limit,
            objectTypeFilter: [],
            keys: []
        ).getValue(domain: .searchService) else { return nil }
            
        let details: [ObjectDetails] = response.records.compactMap { search in
            let idValue = search.fields["id"]
            let idString = idValue?.unwrapedListValue.stringValue
            
            guard let id = idString else { return nil }
            
            return ObjectDetails(id: id, values: search.fields)
        }
            
        return details
    }
}
