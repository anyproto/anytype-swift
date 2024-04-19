struct EditorSetEmptyViewModel {
    let mode: EditorSetEmptyMode
    let onTap: () -> Void
}

enum EditorSetEmptyMode {
    case emptyQuery(canChange: Bool)
    case emptyList(canCreate: Bool)
    
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
    
    var enableAction: Bool {
        switch self {
        case let .emptyQuery(canChange):
            return canChange
        case let .emptyList(canCreate):
            return canCreate
        }
    }
}
