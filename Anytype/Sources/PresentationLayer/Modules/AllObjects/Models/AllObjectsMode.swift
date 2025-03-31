import Services

enum AllObjectsMode: String, CaseIterable {
    case allObjects
    case unlinked
    
    var title: String {
        switch self {
        case .allObjects:
            Loc.allObjects
        case .unlinked:
            Loc.AllObjects.Settings.Unlinked.title
        }
    }
    
    var analyticsValue: String {
        switch self {
        case .allObjects:
            "All"
        case .unlinked:
            "Unlinked"
        }
    }
}
