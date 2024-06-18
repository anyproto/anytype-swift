import Foundation
import Services

final class FilesSearchInteractor {
    
    private let spaceId: String
    private let excludedFileIds: [String]
    
    @Injected(\.searchService)
    private var searchService: SearchServiceProtocol
    
    init(spaceId: String, excludedFileIds: [String]) {
        self.spaceId = spaceId
        self.excludedFileIds = excludedFileIds
    }
    
}

extension FilesSearchInteractor: ObjectsSearchInteractorProtocol {
    
    func search(text: String) async throws -> [ObjectDetails] {
        try await searchService.searchFiles(text: text, excludedFileIds: excludedFileIds, spaceId: spaceId)
    }
    
}
