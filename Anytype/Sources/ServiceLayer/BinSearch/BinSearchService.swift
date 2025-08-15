import ProtobufMessages
import Services
import AnytypeCore

protocol BinSearchServiceProtocol: AnyObject, Sendable {
    func search(text: String, spaceId: String) async throws -> [ObjectDetails]
}

final class BinSearchService: BinSearchServiceProtocol, Sendable {
    
    private let searchMiddleService: any SearchMiddleServiceProtocol = Container.shared.searchMiddleService()
    
    // MARK: - BinSearchServiceProtocol
    
    func search(text: String, spaceId: String) async throws -> [ObjectDetails] {
        let sort = SearchHelper.sort(
            relation: BundledPropertyKey.lastModifiedDate,
            type: .desc
        )
        
        let filters: [DataviewFilter] = .builder {
            SearchHelper.notHiddenFilters(isArchive: true)
        }
        
        return try await searchMiddleService.search(
            spaceId: spaceId,
            filters: filters,
            sorts: [sort],
            fullText: text,
            limit: 1000
        )
    }
}
