import SwiftUI
import Services

enum MenuIcon {
    case asset(ImageAsset)
    case system(String)
}

enum ObjectSettingsSectionType {
    case layout
    case object
}

// Used in ObjectSettingBuilder
enum ObjectSetting: Hashable {
    case icon
    case cover
    case description(isVisible: Bool)
    case relations
    case history
    case resolveConflict
    case webPublishing
    case notifications(mode: SpacePushNotificationsMode)
}

extension ObjectSetting {
    
    var section: ObjectSettingsSectionType {
        switch self {
        case .icon, .cover, .description, .relations, .resolveConflict:
            return .layout
        case .history, .webPublishing, .notifications:
            return .object
        }
    }

    var menuOrder: Int {
        switch self {
        case .relations:
            return 0
        case .icon:
            return 1
        case .cover:
            return 2
        case .description:
            return 10
        case .resolveConflict:
            return 11
        case .webPublishing:
            return 12
        case .notifications:
            return 20
        case .history:
            return 21
        }
    }

    var title: String {
        switch self {
        case .icon:
            Loc.icon
        case .cover:
            Loc.cover
        case .description(let isVisible):
            isVisible ? Loc.hideDescription : Loc.showDescription
        case .relations:
            Loc.fields
        case .history:
            Loc.history
        case .resolveConflict:
            Loc.resolveLayoutConflict
        case .webPublishing:
            Loc.publishToWeb
        case .notifications:
            Loc.notifications
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
            .X24.properties
        case .history:
            .ObjectSettings.history
        case .resolveConflict:
            .X18.attention
        case .webPublishing:
            .X24.web
        case .notifications:
            .PushNotifications.bell
        }
    }

    var menuIcon: MenuIcon {
        switch self {
        case .relations:
            .system("list.bullet")
        default:
            .asset(imageAsset)
        }
    }
}
