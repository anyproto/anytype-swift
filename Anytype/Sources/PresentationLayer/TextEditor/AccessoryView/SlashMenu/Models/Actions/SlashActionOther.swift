import BlocksModels
import AnytypeCore

enum SlashActionOther: CaseIterable, Equatable {
    static var allCases: [SlashActionOther] {
        [.lineDivider, .dotsDivider, .tableOfContents, .table(rowsCount: 3, columnsCount: 3)]
    }

    case lineDivider
    case dotsDivider
    case tableOfContents
    case table(rowsCount: Int, columnsCount: Int)
    
    var title: String {
        switch self {
        case .dotsDivider:
            return Loc.SlashMenu.dotsDivider
        case .lineDivider:
            return Loc.SlashMenu.lineDivider
        case .tableOfContents:
            return Loc.SlashMenu.tableOfContents
        case let .table(rowsCount, columnsCount):
            return Loc.SlashMenu.table + " \(rowsCount)x\(columnsCount)"
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
            return ImageName.slashMenu.other.table
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
