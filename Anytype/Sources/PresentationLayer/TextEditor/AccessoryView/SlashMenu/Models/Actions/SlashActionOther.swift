import BlocksModels
import AnytypeCore

enum SlashActionOther: CaseIterable, Equatable {
    case lineDivider
    case dotsDivider
    case tableOfContents
    case table
    
    var title: String {
        switch self {
        case .dotsDivider:
            return "SlashMenu.DotsDivider".localized
        case .lineDivider:
            return "SlashMenu.LineDivider".localized
        case .tableOfContents:
            return "SlashMenu.TableOfContents".localized
        case .table:
            return "SlashMenu.Table".localized
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
        case .table:
            return ImageName.slashMenu.other.line_divider
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
        case .table:
            return .table
        }
    }
    
    var searchAliases: [String] {
        switch self {
        case .dotsDivider, .lineDivider, .table:
            return []
        case .tableOfContents:
            return ["toc"]
        }
    }
}
