enum DocumentMode: Hashable, Codable {
    case handling
    case preview
    case version(String)
    
    var isHandling: Bool {
        self == .handling
    }
    
    var isVersion: Bool {
        if case .version = self {
            return true
        } else {
            return false
        }
    }
}
