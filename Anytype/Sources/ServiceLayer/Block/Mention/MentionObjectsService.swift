import Services

protocol MentionObjectsServiceProtocol: AnyObject {
    func searchMentions(spaceId: String, text: String, excludedObjectIds: [String]) async throws -> [MentionObject]
    func searchMentions(spaceId: String, text: String, limitLayout: [DetailsLayout]) async throws -> [MentionObject]
}

final class MentionObjectsService: MentionObjectsServiceProtocol {
    
    @Injected(\.searchMiddleService)
    private var searchMiddleService: any SearchMiddleServiceProtocol
    
    func searchMentions(spaceId: String, text: String, excludedObjectIds: [String]) async throws -> [MentionObject] {
        let sort = SearchHelper.sort(
            relation: .lastOpenedDate,
            type: .desc
        )
        
        let filters: [DataviewFilter] = .builder {
            SearchFiltersBuilder.build(isArchived: false, spaceId: spaceId, layouts: DetailsLayout.visibleLayoutsWithFiles)
            SearchHelper.excludedIdsFilter(excludedObjectIds)
        }
        
        let details = try await searchMiddleService.search(filters: filters, sorts: [sort], fullText: text)
        
        return details.map { MentionObject(details: $0) }
    }
    
    func searchMentions(spaceId: String, text: String, limitLayout: [DetailsLayout]) async throws -> [MentionObject] {
        let sort = SearchHelper.sort(
            relation: .lastOpenedDate,
            type: .desc
        )
        
        let filters: [DataviewFilter] = .builder {
            SearchFiltersBuilder.build(isArchived: false, spaceId: spaceId, layouts: limitLayout)
        }
        
        let details = try await searchMiddleService.search(filters: filters, sorts: [sort], fullText: text)
        
        return details.map { MentionObject(details: $0) }
    }
}
