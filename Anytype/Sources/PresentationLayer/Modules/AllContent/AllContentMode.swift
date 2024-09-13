import Services

enum AllContentMode: CaseIterable {
    case allContent
    case unlinked
    
    var title: String {
        switch self {
        case .allContent:
            Loc.allContent
        case .unlinked:
            Loc.AllContent.Mode.unlinked
        }
    }
}
