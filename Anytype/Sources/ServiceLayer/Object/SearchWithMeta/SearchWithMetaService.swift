import ProtobufMessages
import Services
import AnytypeCore

protocol SearchWithMetaServiceProtocol: AnyObject {
    func search(text: String, spaceId: String) async throws -> [SearchResultWithMeta]
    func search(text: String, limitObjectIds: [String]) async throws -> [SearchResultWithMeta]
}

final class SearchWithMetaService: SearchWithMetaServiceProtocol {
    
    @Injected(\.searchWithMetaMiddleService)
    private var searchWithMetaMiddleService: SearchWithMetaMiddleServiceProtocol
    
    // MARK: - SearchServiceProtocol
    
    func search(text: String, spaceId: String) async throws -> [SearchResultWithMeta] {
        try await searchObjectsWithLayouts(text: text, layouts: DetailsLayout.visibleLayouts, spaceId: spaceId)
    }
    
    func search(text: String, limitObjectIds: [String]) async throws -> [SearchResultWithMeta] {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastOpenedDate,
            type: .desc
        )
        let filters: [DataviewFilter] = .builder {
            SearchHelper.includeIdsFilter(limitObjectIds)
            SearchHelper.notHiddenFilters(includeHiddenDiscovery: false)
        }
                
        return try await searchWithMetaMiddleService.search(filters: filters, sorts: [sort], fullText: text)
    }
    
    private func searchObjectsWithLayouts(text: String, layouts: [DetailsLayout], spaceId: String) async throws -> [SearchResultWithMeta] {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastOpenedDate,
            type: .desc
        )
        
        let filters = SearchFiltersBuilder.build(isArchived: false, spaceId: spaceId, layouts: layouts)
        
        return try await searchWithMetaMiddleService.search(filters: filters, sorts: [sort], fullText: text, limit: SearchDefaults.objectsLimit)
    }
}
