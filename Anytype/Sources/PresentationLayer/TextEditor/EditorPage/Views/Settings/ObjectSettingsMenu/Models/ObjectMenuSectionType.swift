import Foundation

enum ObjectMenuSectionType {
    case horizontal
    case mainSettings
    case objectActions
    case management
    case finalActions
}

extension ObjectMenuSectionType {
    static func section(for setting: ObjectSetting) -> ObjectMenuSectionType {
        switch setting {
        case .icon, .cover, .relations:
            return .horizontal
        case .description, .resolveConflict, .webPublishing:
            return .mainSettings
        case .history:
            return .management
        }
    }

    static func section(for action: ObjectAction) -> ObjectMenuSectionType {
        switch action {
        case .pin, .undoRedo:
            return .mainSettings
        case .linkItself, .makeAsTemplate, .templateToggleDefaultState:
            return .objectActions
        case .locked:
            return .management
        case .copyLink, .duplicate, .archive, .delete:
            return .finalActions
        }
    }
}
