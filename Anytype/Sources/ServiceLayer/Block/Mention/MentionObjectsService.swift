protocol MentionObjectsServiceProtocol: AnyObject {
    func searchMentions(text: String, excludedObjectIds: [String]) async throws -> [MentionObject]
}

final class MentionObjectsService: MentionObjectsServiceProtocol {
    
    private let searchService: SearchServiceProtocol
    
    init(searchService: SearchServiceProtocol) {
        self.searchService = searchService
    }
    
    func searchMentions(text: String, excludedObjectIds: [String]) async throws -> [MentionObject] {
        let details = try await searchService.search(text: text, excludedObjectIds: excludedObjectIds)
        return details.map { MentionObject(details: $0) }
    }
}
