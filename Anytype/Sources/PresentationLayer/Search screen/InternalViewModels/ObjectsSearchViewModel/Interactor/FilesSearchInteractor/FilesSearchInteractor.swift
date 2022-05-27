import Foundation
import BlocksModels

final class FilesSearchInteractor {
    
    private let searchService: SearchServiceProtocol
    private let excludedFileIds: [String]
    
    init(searchService: SearchServiceProtocol, excludedFileIds: [String]) {
        self.searchService = searchService
        self.excludedFileIds = excludedFileIds
    }
    
}

extension FilesSearchInteractor: ObjectsSearchInteractorProtocol {
    
    func search(text: String, onCompletion: ([ObjectDetails]) -> ()) {
        let response = searchService.searchFiles(text: text, excludedFileIds: excludedFileIds)
        onCompletion(response ?? [])
    }
    
}
