enum SetViewSettingsMode {
    case new
    case edit
    
    var title: String {
        switch self {
        case .new:
            return Loc.SetViewTypesPicker.New.title
        case .edit:
            return Loc.SetViewTypesPicker.title
        }
    }
    
    var placeholder: String {
        switch self {
        case .new:
            return Loc.SetViewTypesPicker.Settings.Textfield.Placeholder.New.view
        case .edit:
            return Loc.SetViewTypesPicker.Settings.Textfield.Placeholder.untitled
        }
    }
}
