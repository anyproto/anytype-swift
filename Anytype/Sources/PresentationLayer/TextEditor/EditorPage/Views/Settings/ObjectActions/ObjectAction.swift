import BlocksModels


enum ObjectAction: Hashable, Identifiable {
    

    // NOTE: When adding new case here, it case MUST be added in allCasesWith method
    case archive(isArchived: Bool)
    case favorite(isFavorite: Bool)
//    case moveTo
//    case template
//    case search

    // When adding to case
    static func allCasesWith(details: ObjectDetails) -> [Self] {
        var allCases: [ObjectAction] = []

        // We shouldn't allow archive for profile
        if details.type != ObjectTemplateType.profile.rawValue {
            allCases.append(.archive(isArchived: details.isArchived))
        }
        allCases.append(.favorite(isFavorite: details.isFavorite))
//        allCases.append(.moveTo)
//        allCases.append(.template)
//        allCases.append(.search)

        return allCases
    }
    
    var id: String {
        switch self {
        case .archive:
            return "archive"
        case .favorite:
            return "favorite"
        }
    }
}
