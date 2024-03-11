import Foundation

public struct SearchRequest {
    public let filters: [DataviewFilter]
    public let sorts: [DataviewSort]
    public let fullText: String
    public let keys: [String]
    public let limit: Int
    
    public init(filters: [DataviewFilter], sorts: [DataviewSort], fullText: String, keys: [String], limit: Int) {
        self.filters = filters
        self.sorts = sorts
        self.fullText = fullText
        self.keys = keys
        self.limit = limit
    }
}
