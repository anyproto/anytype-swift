enum RelationSettingsMode {
    case create(CreateData)
    case edit(String)
    
    var title: String {
        switch self {
        case .create: return Loc.Relation.View.Create.title
        case .edit: return Loc.Relation.View.Edit.title
        }
    }
    
    var buttonTitle: String {
        switch self {
        case .create: return Loc.create
        case .edit: return Loc.Relation.Edit.Button.title
        }
    }
    
    struct CreateData {
        let relationKey: String
        let spaceId: String
    }
}
