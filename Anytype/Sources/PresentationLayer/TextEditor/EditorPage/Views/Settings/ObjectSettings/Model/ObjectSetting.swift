import SwiftUI


// Used in ObjectSettingBuilder
enum ObjectSetting {
    case icon
    case cover
    case description(isVisible: Bool)
    case relations
    case history
    case resolveConflict
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
        case .resolveConflict:
            Loc.resolveLayoutConflict
        }
    }
    
    var imageAsset: ImageAsset {
        switch self {
        case .icon:
            .ObjectSettings.icon
        case .cover:
            .ObjectSettings.cover
        case .description:
            .ObjectSettings.description
        case .relations:
            .ObjectSettings.relations
        case .history:
            .ObjectSettings.history
        case .resolveConflict:
            .X18.attention
        }
    }
}
