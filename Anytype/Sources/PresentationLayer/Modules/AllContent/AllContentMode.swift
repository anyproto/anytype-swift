import Services

enum AllContentMode: String, CaseIterable {
    case allContent
    case unlinked
    
    var title: String {
        switch self {
        case .allContent:
            Loc.allObjects
        case .unlinked:
            Loc.AllContent.Settings.Unlinked.title
        }
    }
    
    var analyticsValue: String {
        switch self {
        case .allContent:
            "All"
        case .unlinked:
            "Unlinked"
        }
    }
}
