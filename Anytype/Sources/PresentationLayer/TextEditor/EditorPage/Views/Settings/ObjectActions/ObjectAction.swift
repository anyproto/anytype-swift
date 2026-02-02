import Services
import AnytypeCore

enum ObjectAction: Hashable, Identifiable {
    case undoRedo
    case archive(isArchived: Bool)
    case pin(isPinned: Bool)
    case locked(isLocked: Bool)
    case duplicate
    case linkItself
    case makeAsTemplate
    case templateToggleDefaultState(isDefault: Bool)
    case delete
    case copyLink
    case inviteMembers
    case editInfo

    // When adding to case
    static func buildActions(
        details: ObjectDetails,
        isLocked: Bool,
        isPinnedToWidgets: Bool,
        permissions: ObjectPermissions,
        spaceUxType: SpaceUxType?,
        isSpaceOwner: Bool
    ) -> [Self] {
        let canCreateWidget = details.isVisibleLayout(spaceUxType: spaceUxType)
            && !details.isTemplate
            && details.resolvedLayoutValue != .participant
            && permissions.canApplyUneditableActions

        return .builder {
            if permissions.canArchive {
                ObjectAction.archive(isArchived: details.isArchived)
            }

            if canCreateWidget {
                ObjectAction.pin(isPinned: isPinnedToWidgets)
            }
            
            if permissions.canDuplicate {
                ObjectAction.duplicate
            }
            
            if permissions.canUndoRedo {
                ObjectAction.undoRedo
            }
            
            if permissions.canMakeAsTemplate {
                ObjectAction.makeAsTemplate
            }
            
            if permissions.canTemplateSetAsDefault, let targetObjectType = details.targetObjectTypeValue {
                let isDefault = targetObjectType.defaultTemplateId == details.id
                ObjectAction.templateToggleDefaultState(isDefault: isDefault)
            }
            
            if permissions.canLinkItself {
                ObjectAction.linkItself
            }
            
            if permissions.canShare {
                ObjectAction.copyLink
            }

            if details.resolvedLayoutValue.isChat && spaceUxType?.supportsMultiChats == true {
                if permissions.canEditDetails {
                    ObjectAction.editInfo
                }
                if isSpaceOwner {
                    ObjectAction.inviteMembers
                }
            }

            if permissions.canLock {
                ObjectAction.locked(isLocked: isLocked)
            }

            if permissions.canDelete {
                ObjectAction.delete
            }
        }
    }
    
    var id: String {
        switch self {
        case .undoRedo:
            return "undoredo"
        case .archive:
            return "archive"
        case .pin:
            return "pin"
        case .locked:
            return "locked"
        case .duplicate:
            return "duplicate"
        case .linkItself:
            return "linkItself"
        case .makeAsTemplate:
            return "makeAsTemplate"
        case .templateToggleDefaultState:
            return "templateToggleDefaultState"
        case .delete:
            return "delete"
        case .copyLink:
            return "copyLink"
        case .inviteMembers:
            return "inviteMembers"
        case .editInfo:
            return "editInfo"
        }
    }

    var menuOrder: Int {
        switch self {
        case .editInfo:
            return 5
        case .pin:
            return 10
        case .undoRedo:
            return 11
        case .linkItself:
            return 20
        case .makeAsTemplate:
            return 21
        case .templateToggleDefaultState:
            return 22
        case .locked:
            return 30
        case .inviteMembers:
            return 35
        case .copyLink:
            return 40
        case .duplicate:
            return 41
        case .archive:
            return 42
        case .delete:
            return 43
        }
    }
}
