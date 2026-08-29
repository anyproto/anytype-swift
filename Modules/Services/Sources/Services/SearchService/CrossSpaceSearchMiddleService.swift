import Foundation
import ProtobufMessages

public struct CrossSpaceSearchRequest: Sendable {
    public let filters: [DataviewFilter]
    public let sorts: [DataviewSort]
    public let fullText: String
    public let keys: [String]
    public let offset: Int
    public let limit: Int

    public init(filters: [DataviewFilter], sorts: [DataviewSort], fullText: String, keys: [String], offset: Int, limit: Int) {
        self.filters = filters
        self.sorts = sorts
        self.fullText = fullText
        self.keys = keys
        self.offset = offset
        self.limit = limit
    }
}

public struct CrossSpaceSearchResult: Sendable {
    public let records: [ObjectDetails]
    // False right after app start while per-space stores warm up.
    // Render partial results without a retry loop - every keystroke re-queries.
    public let allStoresLoaded: Bool

    public init(records: [ObjectDetails], allStoresLoaded: Bool) {
        self.records = records
        self.allStoresLoaded = allStoresLoaded
    }
}

public protocol CrossSpaceSearchMiddleServiceProtocol: AnyObject, Sendable {
    func search(data: CrossSpaceSearchRequest) async throws -> CrossSpaceSearchResult
}

public extension CrossSpaceSearchMiddleServiceProtocol {
    // limit has no default - unlimited would materialize every space's store
    func search(
        filters: [DataviewFilter] = [],
        sorts: [DataviewSort] = [],
        fullText: String = "",
        keys: [String] = [],
        offset: Int = 0,
        limit: Int
    ) async throws -> CrossSpaceSearchResult {
        try await search(data: CrossSpaceSearchRequest(filters: filters, sorts: sorts, fullText: fullText, keys: keys, offset: offset, limit: limit))
    }
}

final class CrossSpaceSearchMiddleService: CrossSpaceSearchMiddleServiceProtocol {

    func search(data: CrossSpaceSearchRequest) async throws -> CrossSpaceSearchResult {
        let response = try await ClientCommands.objectCrossSpaceSearch(.with {
            $0.filters = data.filters
            $0.sorts = data.sorts.map { $0.fixIncludeTime() }
            $0.fullText = data.fullText
            $0.offset = Int32(data.offset)
            $0.limit = Int32(data.limit)
            $0.keys = data.keys
        }).invoke(qos: .userInitiated)

        return CrossSpaceSearchResult(records: response.records.asDetais, allStoresLoaded: response.allStoresLoaded)
    }
}
