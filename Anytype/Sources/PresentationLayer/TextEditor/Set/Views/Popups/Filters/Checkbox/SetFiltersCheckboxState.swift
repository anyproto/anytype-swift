enum SetFiltersCheckboxState: CaseIterable, Identifiable {
    case checked
    case unchecked
    
    var id: String { title }
    
    var title: String {
        switch self {
        case .checked:
            return Loc.EditSet.Popup.Filter.Value.checked
        case .unchecked:
            return Loc.EditSet.Popup.Filter.Value.unchecked
        }
    }
}
