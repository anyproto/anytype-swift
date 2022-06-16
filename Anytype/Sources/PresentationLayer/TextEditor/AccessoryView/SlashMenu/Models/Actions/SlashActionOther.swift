import BlocksModels
import AnytypeCore

enum SlashActionOther: CaseIterable {
    case lineDivider
    case dotsDivider
    case tableOfContents
    
    var title: String {
        switch self {
        case .dotsDivider:
            return "SlashMenu.DotsDivider".localized
        case .lineDivider:
            return "SlashMenu.LineDivider".localized
        case .tableOfContents:
            return "SlashMenu.TableOfContents".localized
        }
    }
    
    var iconName: String {
        switch self {
        case .dotsDivider:
            return ImageName.slashMenu.other.dots_divider
        case .lineDivider:
            return ImageName.slashMenu.other.line_divider
        case .tableOfContents:
            return ImageName.slashMenu.other.table_of_contents
        }
    }
    
    var blockViewsType: BlockContentType {
        switch self {
        case .dotsDivider:
            return .divider(.dots)
        case .lineDivider:
            return .divider(.line)
        case .tableOfContents:
            return .tableOfContents
        }
    }
    
    var searchAliases: [String] {
        switch self {
        case .dotsDivider, .lineDivider:
            return []
        case .tableOfContents:
            return ["toc"]
        }
    }
    
    static var allCases: Self.AllCases {
        if FeatureFlags.isTableOfContentsAvailable {
            return [.lineDivider, .dotsDivider, .tableOfContents]
        } else {
            return [.lineDivider, .dotsDivider]
        }
    }
}
