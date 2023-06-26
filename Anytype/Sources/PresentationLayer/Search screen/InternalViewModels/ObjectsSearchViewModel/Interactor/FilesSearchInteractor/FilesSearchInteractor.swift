import Foundation
import Services

final class FilesSearchInteractor {
    
    private let searchService: SearchServiceProtocol
    private let excludedFileIds: [String]
    
    init(searchService: SearchServiceProtocol, excludedFileIds: [String]) {
        self.searchService = searchService
        self.excludedFileIds = excludedFileIds
    }
    
}

extension FilesSearchInteractor: ObjectsSearchInteractorProtocol {
    
    func search(text: String) async throws -> [ObjectDetails] {
        try await searchService.searchFiles(text: text, excludedFileIds: excludedFileIds)
    }
    
}
