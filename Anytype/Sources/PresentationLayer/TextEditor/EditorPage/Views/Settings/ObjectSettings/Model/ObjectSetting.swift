import SwiftUI


// Used in ObjectSettingBuilder
enum ObjectSetting {
    case icon
    case cover
    case description(isVisible: Bool)
    case relations
    case history
}

extension ObjectSetting {
    
    var title: String {
        switch self {
        case .icon:
            Loc.icon
        case .cover:
            Loc.cover
        case .description:
            Loc.description
        case .relations:
            Loc.fields
        case .history:
            Loc.history
        }
    }
    
    var imageAsset: ImageAsset {
        switch self {
        case .icon:
            return .ObjectSettings.icon
        case .cover:
            return .ObjectSettings.cover
        case .description:
            return .ObjectSettings.description
        case .relations:
            return .ObjectSettings.relations
        case .history:
            return .ObjectSettings.history
        }
    }
}
