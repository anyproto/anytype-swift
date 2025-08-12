struct SlashMenuItemDisplayData {
    let iconData: Icon
    let title: String
    let titleSynonyms: [String]
    let searchAliases: [String]
    let expandedIcon: Bool
    let showDecoration: Bool
    
    init(
        iconData: Icon,
        title: String,
        titleSynonyms: [String] = [],
        searchAliases: [String] = [],
        expandedIcon: Bool = false,
        showDecoration: Bool = false
    ) {
        self.iconData = iconData
        self.title = title
        self.titleSynonyms = titleSynonyms
        self.searchAliases = searchAliases
        self.expandedIcon = expandedIcon
        self.showDecoration = showDecoration
    }
}


enum NewSlashMenuItemDisplayData: ComparableDisplayData {
    case titleDisplayData(SlashMenuItemDisplayData)
    case relationDisplayData(Property)

    var title: String? {
        switch self {
        case let .titleDisplayData(slashMenuItemDisplayData):
            return slashMenuItemDisplayData.title
        case let .relationDisplayData(relation):
            return relation.name
        }
    }
    
    var aliases: [String]? {
        switch self {
        case let .titleDisplayData(slashMenuItemDisplayData):
            return slashMenuItemDisplayData.searchAliases
        case .relationDisplayData:
            return nil
        }
    }
    
    var titleSynonyms: [String]? {
        switch self {
        case let .titleDisplayData(slashMenuItemDisplayData):
            return slashMenuItemDisplayData.titleSynonyms
        case .relationDisplayData:
            return nil
        }
    }
}
