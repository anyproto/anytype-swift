import Foundation

public struct PasteboardFile {
    public let path: String
    public let name: String
    
    public init(path: String, name: String) {
        self.path = path
        self.name = name
    }
}
