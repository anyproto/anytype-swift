import Services
import AnytypeCore

enum ObjectAction: Hashable, Identifiable {
    case undoRedo
    case archive(isArchived: Bool)
    case favorite(isFavorite: Bool)
    case locked(isLocked: Bool)
    case duplicate
    case linkItself
    case makeAsTemplate
    case templateToggleDefaultState(isDefault: Bool)
    case delete
    case createWidget
    case copyLink

    // When adding to case
    static func buildActions(details: ObjectDetails, isLocked: Bool, permissions: ObjectPermissions) -> [Self] {
        .builder {
            if permissions.canArchive {
                ObjectAction.archive(isArchived: details.isArchived)
            }
            
            if permissions.canFavorite {
                ObjectAction.favorite(isFavorite: details.isFavorite)
            }
            
            if permissions.canCreateWidget {
                ObjectAction.createWidget
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
        case .favorite:
            return "favorite"
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
        case .createWidget:
            return "createWidget"
        case .copyLink:
            return "copyLink"
        }
    }
}
