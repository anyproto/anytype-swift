struct EditorSetEmptyViewModel {
    let mode: Mode
    let onTap: () -> Void
    
    enum Mode {
        case set
        case collection
        
        var title: String {
            switch self {
            case .set:
                return Loc.Set.View.Empty.title
            case .collection:
                return Loc.Collection.View.Empty.title
            }
        }
        
        var subtitle: String {
            switch self {
            case .set:
                return Loc.Set.View.Empty.subtitle
            case .collection:
                return Loc.Collection.View.Empty.subtitle
            }
        }
        
        var buttonTitle: String {
            switch self {
            case .set:
                return Loc.Set.SourceType.selectQuery
            case .collection:
                return Loc.Collection.View.Empty.Button.title
            }
        }
    }
}
