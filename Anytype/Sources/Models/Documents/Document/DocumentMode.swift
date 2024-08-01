enum DocumentMode: Equatable {
    case handling
    case preview
    case version(String)
    
    var isHandling: Bool {
        self == .handling
    }
}
