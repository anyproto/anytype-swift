import Foundation

enum ObjectMenuSectionType {
    case horizontal
    case descriptionSection
    case mainSettings
    case moreCollapsible
    case finalActions
}

extension ObjectMenuSectionType {
    static func section(for setting: ObjectSetting) -> ObjectMenuSectionType {
        switch setting {
        case .icon, .cover, .relations:
            return .horizontal
        case .description:
            return .descriptionSection
        case .resolveConflict, .webPublishing:
            return .mainSettings
        case .history:
            return .moreCollapsible
        }
    }

    static func section(for action: ObjectAction) -> ObjectMenuSectionType {
        switch action {
        case .pin, .undoRedo, .copyLink:
            return .mainSettings
        case .linkItself, .locked, .makeAsTemplate:
            return .moreCollapsible
        case .templateToggleDefaultState, .duplicate, .archive, .delete:
            return .finalActions
        }
    }
}
