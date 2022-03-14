import Foundation
import BlocksModels

final class ObjectsSearchInteractor {
    
    private let searchService: SearchServiceProtocol
    private let selectedObjectIds: [String]
    
    init(searchService: SearchServiceProtocol, selectedObjectIds: [String]) {
        self.searchService = searchService
        self.selectedObjectIds = selectedObjectIds
    }
    
}

extension ObjectsSearchInteractor: ObjectsSearchInteractorProtocol {
    
    func search(text: String, onCompletion: ([ObjectDetails]) -> ()) {
        let response = searchService.search(text: text)
        let filteredResponse = response?.filter { !selectedObjectIds.contains($0.id) }
        
        onCompletion(filteredResponse ?? [])
    }
    
}
