import Foundation

public struct PasteboardFile: Sendable {
    public let path: String
    public let name: String
    
    public init(path: String, name: String) {
        self.path = path
        self.name = name
    }
}
