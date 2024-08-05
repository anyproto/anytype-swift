enum DocumentMode: Hashable, Codable {
    case handling
    case preview
    case version(String)
    
    var isHandling: Bool {
        self == .handling
    }
}
