import AnytypeCore

enum EditorSetSetting: CaseIterable, Identifiable {
    var id: String { name }
    
//    case view
    case settings
    case sort
    case filter
//    case group
    
    var name: String {
        switch self {
//        case .view:
//            return Loc.view
        case .settings:
            return Loc.settings
        case .sort:
            return Loc.sort
        case .filter:
            return Loc.filter
//        case .group:
//            return Loc.group
        }
    }
    
    var imageAsset: ImageAsset {
        switch self {
//        case .view:
//            return .set.view
        case .settings:
            return .setSettingsSettings
        case .sort:
            return .setSettinsSort
        case .filter:
            return .setSettinsFilter
//        case .group:
//            return .set.group
        }
    }
    
    static var allCases: Self.AllCases {
        var cases: [EditorSetSetting] = [.settings, .sort]
        
        if FeatureFlags.isSetFiltersAvailable {
            cases.append(.filter)
        }
        
        return cases
    }
}
