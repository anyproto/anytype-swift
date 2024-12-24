import ProtobufMessages
import Services
import AnytypeCore

protocol SearchWithMetaServiceProtocol: AnyObject, Sendable {
    func search(text: String, spaceId: String) async throws -> [SearchResultWithMeta]
    func search(text: String, spaceId: String, limitObjectIds: [String]) async throws -> [SearchResultWithMeta]
}

final class SearchWithMetaService: SearchWithMetaServiceProtocol, Sendable {
    
    private let searchWithMetaMiddleService: any SearchWithMetaMiddleServiceProtocol = Container.shared.searchWithMetaMiddleService()
    
    // MARK: - SearchServiceProtocol
    
    func search(text: String, spaceId: String) async throws -> [SearchResultWithMeta] {
        try await searchObjectsWithLayouts(
            text: text,
            layouts: DetailsLayout.visibleLayoutsWithFiles,
            spaceId: spaceId
        )
    }
    
    func search(text: String, spaceId: String, limitObjectIds: [String]) async throws -> [SearchResultWithMeta] {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastOpenedDate,
            type: .desc
        )
        let filters: [DataviewFilter] = .builder {
            SearchHelper.includeIdsFilter(limitObjectIds)
            SearchHelper.notHiddenFilters()
        }
        return try await searchWithMetaMiddleService.search(spaceId: spaceId, filters: filters, sorts: [sort], fullText: text)
    }
    
    private func searchObjectsWithLayouts(text: String, layouts: [DetailsLayout], spaceId: String) async throws -> [SearchResultWithMeta] {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastOpenedDate,
            type: .desc
        )
        
        let filters = SearchFiltersBuilder.build(isArchived: false, layouts: layouts)
        
        return try await searchWithMetaMiddleService.search(spaceId: spaceId, filters: filters, sorts: [sort], fullText: text, limit: SearchDefaults.objectsLimit)
    }
}
