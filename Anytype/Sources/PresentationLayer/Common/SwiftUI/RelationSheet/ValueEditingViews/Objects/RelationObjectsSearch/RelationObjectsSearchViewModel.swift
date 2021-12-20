import Foundation

final class RelationObjectsSearchViewModel: ObservableObject {
    
    @Published var selectedObjectIds: [String] = []
    @Published var objects: [RelationObjectsSearchData] = []
    
    private let excludeObjectIds: [String]
    private let addObjectAction: ([String]) -> Void
    private let service = SearchService()
    
    init(excludeObjectIds: [String], addTagsAction: @escaping ([String]) -> Void) {
        self.excludeObjectIds = excludeObjectIds
        self.addObjectAction = addTagsAction
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
    
    func didTapOnObject(_ object: RelationObjectsSearchData) {
        let id = object.id
        if selectedObjectIds.contains(id) {
            selectedObjectIds = selectedObjectIds.filter { $0 != id }
        } else {
            selectedObjectIds.append(id)
        }
    }
    
    func didTapAddSelectedObjects() {
        addObjectAction(selectedObjectIds)
    }
    
}
