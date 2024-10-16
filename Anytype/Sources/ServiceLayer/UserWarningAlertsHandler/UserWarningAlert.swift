enum UserWarningAlert: Identifiable, Codable, CaseIterable {
    case reindexing
    
    var version: String {
        switch self {
        case .reindexing: "0.33.0"
        }
    }
    
    var ignoreForNewUser: Bool {
        switch self {
        case .reindexing: true
        }
    }
    
    var id: Self { self }
}
