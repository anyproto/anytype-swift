import Services
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
    
    var iconAsset: ImageAsset {
        switch self {
        case .dotsDivider:
            return .X40.Divider.dots
        case .lineDivider:
            return .X40.Divider.line
        case .tableOfContents:
            return .X32.tableOfContents
        case .table:
            return .X40.simpleTables
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
