import Foundation

public struct SharedContentDebugInfo: Codable {
    public let items: [SharedContentDebugItem]
}

public struct SharedContentDebugItem: Codable {
    public let mimeTypes: [String]
}
