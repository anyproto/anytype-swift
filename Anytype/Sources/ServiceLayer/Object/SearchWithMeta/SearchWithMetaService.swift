import ProtobufMessages
import Services
import AnytypeCore

protocol SearchWithMetaServiceProtocol: AnyObject, Sendable {
    func search(text: String, spaceId: String, sorts: [DataviewSort]) async throws -> [SearchResultWithMeta]
}

final class SearchWithMetaService: SearchWithMetaServiceProtocol, Sendable {
    
    private let searchWithMetaMiddleService: any SearchWithMetaMiddleServiceProtocol = Container.shared.searchWithMetaMiddleService()
    
    // MARK: - SearchServiceProtocol
    
    func search(text: String, spaceId: String, sorts: [DataviewSort]) async throws -> [SearchResultWithMeta] {
        try await searchObjectsWithLayouts(
            text: text,
            spaceId: spaceId,
            layouts: DetailsLayout.visibleLayoutsWithFiles,
            sorts: sorts
        )
    }
    
    private func searchObjectsWithLayouts(text: String, spaceId: String, layouts: [DetailsLayout], sorts: [DataviewSort]) async throws -> [SearchResultWithMeta] {
        
        let filters = SearchFiltersBuilder.build(isArchived: false, layouts: layouts)
        
        return try await searchWithMetaMiddleService.search(spaceId: spaceId, filters: filters, sorts: sorts, fullText: text, limit: SearchDefaults.objectsLimit)
    }
}
