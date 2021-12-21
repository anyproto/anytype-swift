import Foundation

final class RelationObjectsSearchViewModel: ObservableObject {
    
    @Published var objects: [RelationObjectsSearchData] = []
    
    private let excludeObjectIds: [String]
    
    private let service = SearchService()
    
    init(excludeObjectIds: [String]) {
        self.excludeObjectIds = excludeObjectIds
    }
    
}

extension RelationObjectsSearchViewModel {
    
    func search(text: String) {
        let result = service.search(text: text)?.filter { !excludeObjectIds.contains($0.id) }
        
        guard let result = result, result.isNotEmpty else {
            objects = []
            return
        }

        objects = result.map { RelationObjectsSearchData(searchData: $0) }
    }
    
}
