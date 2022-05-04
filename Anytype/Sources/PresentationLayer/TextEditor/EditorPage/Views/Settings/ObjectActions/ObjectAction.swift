import BlocksModels


enum ObjectAction: Hashable, Identifiable {
    // NOTE: When adding new case here, it case MUST be added in allCasesWith method
    case archive(isArchived: Bool)
    case favorite(isFavorite: Bool)
    case locked(isLocked: Bool)

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

        if details.objectType.url != ObjectTemplateType.bundled(.set).rawValue {
            allCases.append(.locked(isLocked: isLocked))
        }

        return allCases
    }
    
    var id: String {
        switch self {
        case .archive:
            return "archive"
        case .favorite:
            return "favorite"
        case .locked:
            return "locked"
        }
    }
}
