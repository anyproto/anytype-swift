import Foundation
import ProtobufMessages

public protocol SearchWithMetaMiddleServiceProtocol: AnyObject, Sendable {
    func search(data: SearchRequest) async throws -> [SearchResultWithMeta]
}

public extension SearchWithMetaMiddleServiceProtocol {
    func search(
        filters: [DataviewFilter] = [],
        sorts: [DataviewSort] = [],
        fullText: String = "",
        keys: [String] = [],
        limit: Int = 0
    ) async throws -> [SearchResultWithMeta] {
        try await search(data: SearchRequest(filters: filters, sorts: sorts, fullText: fullText, keys: keys, limit: limit))
    }
}

final class SearchWithMetaMiddleService: SearchWithMetaMiddleServiceProtocol {
    
    // MARK: - SearchServiceProtocol
    
    public func search(data: SearchRequest) async throws -> [SearchResultWithMeta] {
        let response = try await ClientCommands.objectSearchWithMeta(.with {
            $0.filters = data.filters
            $0.sorts = data.sorts.map { $0.fixIncludeTime() }
            $0.fullText = data.fullText
            $0.limit = Int32(data.limit)
            $0.keys = data.keys
            $0.returnMeta = true
        }).invoke()
        
        return response.results.asResults
    }
}
