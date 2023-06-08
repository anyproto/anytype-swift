import BlocksModels
import AnytypeCore

enum ObjectAction: Hashable, Identifiable {
    // NOTE: When adding new case here, it case MUST be added in allCasesWith method
    case undoRedo
    case archive(isArchived: Bool)
    case favorite(isFavorite: Bool)
    case locked(isLocked: Bool)
    case duplicate
    case linkItself

    // When adding to case
    static func allCasesWith(
        details: ObjectDetails,
        objectRestrictions: ObjectRestrictions,
        isLocked: Bool
    ) -> [Self] {
        var allCases: [ObjectAction] = []

        // We shouldn't allow archive for profile
        if !objectRestrictions.objectRestriction.contains(.delete) {
            allCases.append(.archive(isArchived: details.isArchived))
        }

        allCases.append(.favorite(isFavorite: details.isFavorite))
        
        if !objectRestrictions.objectRestriction.contains(.duplicate) {
            allCases.append(.duplicate)
        }

        if details.objectType.id != ObjectTypeId.bundled(.set).rawValue &&
            details.objectType.id != ObjectTypeId.bundled(.collection).rawValue
        {
            allCases.append(.undoRedo)
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
        }
    }
}
