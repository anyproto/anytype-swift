enum UserWarningAlert: Identifiable, Codable {
    case reindexing
    
    var version: String {
        switch self {
            case .reindexing: "0.34.0"
        }
    }
    
    var ignoreForNewUser: Bool {
        switch self {
            case .reindexing: true
        }
    }
    
    var id: Self { self }
}
