import Foundation

public struct SearchRequest: Sendable {
    public let spaceId: String
    public let filters: [DataviewFilter]
    public let sorts: [DataviewSort]
    public let fullText: String
    public let keys: [String]
    public let limit: Int
    
    public init(spaceId: String, filters: [DataviewFilter], sorts: [DataviewSort], fullText: String, keys: [String], limit: Int) {
        self.spaceId = spaceId
        self.filters = filters
        self.sorts = sorts
        self.fullText = fullText
        self.keys = keys
        self.limit = limit
    }
}
