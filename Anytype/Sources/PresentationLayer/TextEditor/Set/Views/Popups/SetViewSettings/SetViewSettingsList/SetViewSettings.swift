enum SetViewSettings: CaseIterable {
    case layout
    case relations
    case filters
    case sorts
    
    var title: String {
        switch self {
        case .layout:
            return Loc.layout
        case .relations:
            return Loc.fields
        case .filters:
            return Loc.EditSet.Popup.Filters.NavigationView.title
        case .sorts:
            return Loc.EditSet.Popup.Sorts.NavigationView.title
        }
    }
    
    var placeholder: String {
        switch self {
        case .layout:
            return ""
        case .relations:
            return Loc.Set.View.Settings.NoRelations.placeholder
        case .filters:
            return Loc.Set.View.Settings.NoFilters.placeholder
        case .sorts:
            return Loc.Set.View.Settings.NoSorts.placeholder
        }
    }
    
    var isLast: Bool {
        self == SetViewSettings.allCases.last
    }
    
    func isPlaceholder(_ text: String) -> Bool {
        text == placeholder || text == Loc.EditorSet.View.Not.Supported.title
    }
}
