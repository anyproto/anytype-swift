import Services

protocol MentionObjectsServiceProtocol: AnyObject {
    func searchMentions(spaceId: String, text: String, excludedObjectIds: [String]) async throws -> [MentionObject]
}

final class MentionObjectsService: MentionObjectsServiceProtocol {
    
    @Injected(\.searchService)
    private var searchService:any SearchServiceProtocol
    
    func searchMentions(spaceId: String, text: String, excludedObjectIds: [String]) async throws -> [MentionObject] {
        let details = try await searchService.searchObjects(
            text: text,
            excludedObjectIds: excludedObjectIds,
            excludedLayouts: [],
            spaceId: spaceId,
            sortRelationKey: nil
        )
        return details.map { MentionObject(details: $0) }
    }
}
