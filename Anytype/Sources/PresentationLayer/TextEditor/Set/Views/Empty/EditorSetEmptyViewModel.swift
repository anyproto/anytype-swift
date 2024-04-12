struct EditorSetEmptyViewModel {
    let mode: EditorSetEmptyMode
    let allowTap: Bool
    let onTap: () -> Void
}

enum EditorSetEmptyMode {
    case emptyQuery
    case emptyList
    
    var title: String {
        switch self {
        case .emptyQuery:
            return Loc.Set.View.Empty.title
        case .emptyList:
            return Loc.Collection.View.Empty.title
        }
    }
    
    var subtitle: String {
        switch self {
        case .emptyQuery:
            return Loc.Set.View.Empty.subtitle
        case .emptyList:
            return Loc.Collection.View.Empty.subtitle
        }
    }
    
    var buttonTitle: String {
        switch self {
        case .emptyQuery:
            return Loc.Set.SourceType.selectQuery
        case .emptyList:
            return Loc.Collection.View.Empty.Button.title
        }
    }
}
