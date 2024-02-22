import Foundation
import ProtobufMessages

public protocol SearchMiddleServiceProtocol: AnyObject {
    func search(data: SearchRequest) async throws -> [ObjectDetails]
}

public extension SearchMiddleServiceProtocol {
    func search(
        filters: [DataviewFilter] = [],
        sorts: [DataviewSort] = [],
        fullText: String = "",
        keys: [String] = [],
        limit: Int = 0
    ) async throws -> [ObjectDetails] {
        try await search(data: SearchRequest(filters: filters, sorts: sorts, fullText: fullText, keys: keys, limit: limit))
    }
}

public final class SearchMiddleService: SearchMiddleServiceProtocol {
    
    public init() {}
    
    // MARK: - SearchServiceProtocol
    
    public func search(data: SearchRequest) async throws -> [ObjectDetails] {
        let response = try await ClientCommands.objectSearch(.with {
            $0.filters = data.filters
            $0.sorts = data.sorts.map { $0.fixIncludeTime() }
            $0.fullText = data.fullText
            $0.limit = Int32(data.limit)
            $0.keys = data.keys
        }).invoke()
        
        return response.records.asDetais
    }
}
