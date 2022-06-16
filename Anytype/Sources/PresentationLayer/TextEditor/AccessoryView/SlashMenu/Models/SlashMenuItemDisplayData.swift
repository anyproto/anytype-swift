import Foundation

struct SlashMenuItemDisplayData {
    let iconData: ObjectIconImage
    let title: String
    let subtitle: String?
    let searchAliases: [String]
    let expandedIcon: Bool
    
    init(iconData: ObjectIconImage, title: String, subtitle: String? = nil, searchAliases: [String] = [], expandedIcon: Bool = false) {
        self.iconData = iconData
        self.title = title
        self.subtitle = subtitle
        self.searchAliases = searchAliases
        self.expandedIcon = expandedIcon
    }
}


enum NewSlashMenuItemDisplayData: ComparableDisplayData {
    case titleSubtitleDisplayData(SlashMenuItemDisplayData)
    case relationDisplayData(Relation)

    var title: String? {
        switch self {
        case let .titleSubtitleDisplayData(slashMenuItemDisplayData):
            return slashMenuItemDisplayData.title
        case let .relationDisplayData(relation):
            return relation.name
        }
    }

    var subtitle: String? {
        switch self {
        case let .titleSubtitleDisplayData(slashMenuItemDisplayData):
            return slashMenuItemDisplayData.subtitle
        case .relationDisplayData:
            return nil
        }
    }
    
    var aliases: [String]? {
        switch self {
        case let .titleSubtitleDisplayData(slashMenuItemDisplayData):
            return slashMenuItemDisplayData.searchAliases
        case .relationDisplayData:
            return nil
        }
    }
}
