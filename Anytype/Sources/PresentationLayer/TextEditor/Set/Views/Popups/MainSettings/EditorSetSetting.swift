import AnytypeCore

enum EditorSetSetting: CaseIterable, Identifiable {
    var id: String { name }
    
    case view
    case settings
    case sort
    case filter
//    case group
    
    var name: String {
        switch self {
        case .view:
            return Loc.view
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
        case .view:
            return .X32.View.view
        case .settings:
            return .X32.properties
        case .sort:
            return .X32.sort
        case .filter:
            return .X32.filter
//        case .group:
//            return .set.group
        }
    }
}
