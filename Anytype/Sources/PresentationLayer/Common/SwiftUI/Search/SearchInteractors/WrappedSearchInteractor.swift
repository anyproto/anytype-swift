import Foundation
import Services

final class WrappedSearchInteractor: SearchInteractorProtocol {
    private let searchService: SearchServiceProtocol
    
    init(searchService: SearchServiceProtocol) {
        self.searchService = searchService
    }
    
    func search(text: String, spaceId: String) async throws -> [ObjectDetails] {
        try await searchService.search(text: text, spaceId: spaceId)
    }
}
