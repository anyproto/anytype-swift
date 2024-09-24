import Services

enum AllContentMode: String, CaseIterable {
    case allContent
    case unlinked
    
    var title: String {
        switch self {
        case .allContent:
            Loc.allContent
        case .unlinked:
            Loc.AllContent.Settings.Unlinked.title
        }
    }
}
