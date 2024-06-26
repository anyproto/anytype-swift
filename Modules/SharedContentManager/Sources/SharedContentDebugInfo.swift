import Foundation

public struct SharedContentDebugInfo: Codable, Sendable {
    public let items: [SharedContentDebugItem]
}

public struct SharedContentDebugItem: Codable, Sendable {
    public let mimeTypes: [String]
}
