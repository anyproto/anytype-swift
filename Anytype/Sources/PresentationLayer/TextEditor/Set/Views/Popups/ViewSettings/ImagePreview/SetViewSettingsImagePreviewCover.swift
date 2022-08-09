enum SetViewSettingsImagePreviewCover: String, CaseIterable, Identifiable {
    case none = ""
    case pageCover
    
    var id: String {
        rawValue
    }
    
    var title: String {
        switch self {
        case .none:
            return Loc.none
        case .pageCover:
            return Loc.cover
        }
    }
}
