import ProtobufMessages
import Services
import AnytypeCore

protocol SearchWithMetaServiceProtocol: AnyObject, Sendable {
    func search(text: String, spaceId: String, layouts: [DetailsLayout], sorts: [DataviewSort]) async throws -> [SearchResultWithMeta]
}

final class SearchWithMetaService: SearchWithMetaServiceProtocol, Sendable {
    
    private let searchWithMetaMiddleService: any SearchWithMetaMiddleServiceProtocol = Container.shared.searchWithMetaMiddleService()
    
    // MARK: - SearchServiceProtocol
    
    func search(text: String, spaceId: String, layouts: [DetailsLayout], sorts: [DataviewSort]) async throws -> [SearchResultWithMeta] {
        
        let filters = SearchFiltersBuilder.build(isArchived: false, layouts: layouts)
        
        return try await searchWithMetaMiddleService.search(spaceId: spaceId, filters: filters, sorts: sorts, fullText: text, limit: SearchDefaults.objectsLimit)
    }
}
