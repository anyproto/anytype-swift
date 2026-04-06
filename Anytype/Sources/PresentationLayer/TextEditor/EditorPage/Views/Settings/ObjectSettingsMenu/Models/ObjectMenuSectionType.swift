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
        case .description, .prefillName:
            return .descriptionSection
        case .resolveConflict, .webPublishing, .notifications:
            return .mainSettings
        case .history:
            return .moreCollapsible
        }
    }

    static func section(for action: ObjectAction, isChat: Bool) -> ObjectMenuSectionType {
        switch action {
        case .editInfo:
            return .horizontal
        case .pin:
            return .mainSettings
        case .undoRedo, .copyLink, .inviteMembers:
            return .mainSettings
        case .linkItself, .locked, .makeAsTemplate:
            return .moreCollapsible
        case .templateToggleDefaultState, .duplicate, .archive, .delete:
            return .finalActions
        }
    }
}
