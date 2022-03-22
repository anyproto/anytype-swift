import Foundation
import BlocksModels

final class FilesSearchInteractor {
    
    private let searchService: SearchServiceProtocol
    private let selectedObjectIds: [String]
    
    init(searchService: SearchServiceProtocol, selectedObjectIds: [String]) {
        self.searchService = searchService
        self.selectedObjectIds = selectedObjectIds
    }
    
}

extension FilesSearchInteractor: ObjectsSearchInteractorProtocol {
    
    func search(text: String, onCompletion: ([ObjectDetails]) -> ()) {
        let response = searchService.searchFiles(text: text)
        let filteredResponse = response?.filter { !selectedObjectIds.contains($0.id) }
        
        onCompletion(filteredResponse ?? [])
    }
    
}
