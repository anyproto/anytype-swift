import Services
import AnytypeCore

enum ObjectAction: Hashable, Identifiable {
    // NOTE: When adding new case here, it case MUST be added in allCasesWith method
    case undoRedo
    case archive(isArchived: Bool)
    case favorite(isFavorite: Bool)
    case locked(isLocked: Bool)
    case duplicate
    case linkItself
    case makeAsTemplate
    case templateSetAsDefault
    case delete
    case createWidget

    // When adding to case
    static func allCasesWith(
        details: ObjectDetails,
        objectRestrictions: ObjectRestrictions,
        isLocked: Bool,
        isArchived: Bool
    ) -> [Self] {
        
        if isArchived {
            return actionsForArchiveObject()
        }
        
        if details.isTemplateType {
            return [
                .archive(isArchived: details.isArchived),
                .templateSetAsDefault,
                .duplicate,
                .undoRedo
            ]
        }
        
        var allCases: [ObjectAction] = []
        
        // We shouldn't allow archive for profile
        if !objectRestrictions.objectRestriction.contains(.delete) {
            allCases.append(.archive(isArchived: details.isArchived))
        }
        
        if details.isVisibleLayout, !details.isTemplateType, details.layoutValue != .participant {
            allCases.append(.createWidget)
        }

        allCases.append(.favorite(isFavorite: details.isFavorite))
        
        if !objectRestrictions.objectRestriction.contains(.duplicate) {
            allCases.append(.duplicate)
        }

        if details.layoutValue != .set && details.layoutValue != .collection && details.layoutValue != .participant {
            allCases.append(.undoRedo)
            
            if details.canMakeTemplate && !objectRestrictions.objectRestriction.contains(.template) {
                allCases.append(.makeAsTemplate)
            }
            
            allCases.append(.linkItself)
            allCases.append(.locked(isLocked: isLocked))
        } else {
            allCases.append(.linkItself)
        }

        return allCases
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
        case .templateSetAsDefault:
            return "templateSetAsDefault"
        case .delete:
            return "delete"
        case .createWidget:
            return "createWidget"
        }
    }
    
    private static func actionsForArchiveObject() -> [Self] {
        return [
            .delete,
            .archive(isArchived: true)
        ]
    }
}
