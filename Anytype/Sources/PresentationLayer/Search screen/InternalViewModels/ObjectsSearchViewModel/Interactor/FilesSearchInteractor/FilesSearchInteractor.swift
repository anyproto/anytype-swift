import Foundation
import Services

final class FilesSearchInteractor {
    
    private let spaceId: String
    private let searchService: SearchServiceProtocol
    private let excludedFileIds: [String]
    
    init(spaceId: String, searchService: SearchServiceProtocol, excludedFileIds: [String]) {
        self.spaceId = spaceId
        self.searchService = searchService
        self.excludedFileIds = excludedFileIds
    }
    
}

extension FilesSearchInteractor: ObjectsSearchInteractorProtocol {
    
    func search(text: String) async throws -> [ObjectDetails] {
        try await searchService.searchFiles(text: text, excludedFileIds: excludedFileIds, spaceId: spaceId)
    }
    
}
