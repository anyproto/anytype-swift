enum SetViewSettings: CaseIterable {
    case defaultObject
    case layout
    case relations
    case filters
    case sorts
    
    var title: String {
        switch self {
        case .defaultObject:
            return Loc.Set.View.Settings.DefaultObject.title
        case .layout:
            return Loc.layout
        case .relations:
            return Loc.relations
        case .filters:
            return Loc.EditSet.Popup.Filters.NavigationView.title
        case .sorts:
            return Loc.EditSet.Popup.Sorts.NavigationView.title
        }
    }
    
    var isLast: Bool {
        self == SetViewSettings.allCases.last
    }
}
