enum SetObjectCreationSettingsMode {
    case creation
    case `default`
    
    var title: String {
        switch self {
        case .creation:
            return Loc.createObject
        case .default:
            return Loc.Set.View.Settings.DefaultObject.title
        }
    }
}
