import Services

protocol SearchInteractorProtocol: AnyObject {
    func search(text: String, spaceId: String) async throws -> [ObjectDetails]
}

final class ObjectLayoutSearch: SearchInteractorProtocol {
    let layouts: [DetailsLayout]
    let searchService: SearchServiceProtocol
    
    init(layouts: [DetailsLayout], searchService: SearchServiceProtocol) {
        self.layouts = layouts
        self.searchService = searchService
    }
    
    func search(text: String, spaceId: String) async throws -> [ObjectDetails] {
        try await searchService.searchObjectsWithLayouts(text: text, layouts: layouts, spaceId: spaceId)
    }
}
