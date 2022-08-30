import UIKit

private typealias L10n = Loc.SimpleTableMenu.Item
private typealias BlockOptionImage = ImageAsset.TextEditor.BlocksOption

enum SimpleTableCellMenuItem: CaseIterable {
    case clearContents
    case color
    case style
    case clearStyle

    var title: String {
        switch self {
        case .clearContents:
            return L10n.clearContents
        case .color:
            return L10n.color
        case .style:
            return L10n.style
        case .clearStyle:
            return L10n.clearStyle
        }
    }

    var imageAsset: ImageAsset {
        switch self {
        case .clearContents:
            return BlockOptionImage.cellMenuClear
        case .color:
            return BlockOptionImage.cellMenuColor
        case .style:
            return .EditingToolbar.style
        case .clearStyle:
            return BlockOptionImage.cellMenuClear
        }
    }
}

enum SimpleTableColumnMenuItem: CaseIterable {
    case insertLeft
    case insertRight
    case moveLeft
    case moveRight
    case duplicate
    case delete
    case clearContents
    case sort
    case color
    case style

    var title: String {
        switch self {
        case .insertLeft:
            return L10n.insertLeft
        case .insertRight:
            return L10n.insertRight
        case .moveLeft:
            return L10n.moveLeft
        case .moveRight:
            return L10n.moveRight
        case .duplicate:
            return L10n.duplicate
        case .delete:
            return L10n.delete
        case .clearContents:
            return L10n.clearContents
        case .sort:
            return L10n.sort
        case .color:
            return L10n.color
        case .style:
            return L10n.style
        }
    }

    var imageAsset: ImageAsset {
        switch self {
        case .insertLeft:
            return BlockOptionImage.columnInsertLeft
        case .insertRight:
            return BlockOptionImage.columnInsertRight
        case .moveLeft:
            return BlockOptionImage.columnMoveLeft
        case .moveRight:
            return BlockOptionImage.columnMoveRight
        case .duplicate:
            return BlockOptionImage.duplicate
        case .delete:
            return BlockOptionImage.delete
        case .clearContents:
            return BlockOptionImage.cellMenuClear
        case .sort:
            return BlockOptionImage.columnSort
        case .color:
            return BlockOptionImage.cellMenuColor
        case .style:
            return .EditingToolbar.style
        }
    }
}

enum SimpleTableRowMenuItem: CaseIterable {
    case insertAbove
    case insertBelow
    case moveUp
    case moveDown
    case duplicate
    case delete
    case clearContents
    case color
    case style

    var title: String {
        switch self {
        case .insertAbove:
            return L10n.insertAbove
        case .insertBelow:
            return L10n.insertBelow
        case .moveUp:
            return L10n.moveUp
        case .moveDown:
            return L10n.moveDown
        case .duplicate:
            return L10n.duplicate
        case .delete:
            return L10n.delete
        case .clearContents:
            return L10n.clearContents
        case .color:
            return L10n.color
        case .style:
            return L10n.style
        }
    }

    var imageAsset: ImageAsset {
        switch self {
        case .insertAbove:
            return BlockOptionImage.rowInsertAbove
        case .insertBelow:
            return BlockOptionImage.rowInsertBelow
        case .moveUp:
            return BlockOptionImage.rowMoveUp
        case .moveDown:
            return BlockOptionImage.rowMoveDown
        case .duplicate:
            return BlockOptionImage.duplicate
        case .delete:
            return BlockOptionImage.delete
        case .clearContents:
            return BlockOptionImage.cellMenuClear
        case .color:
            return BlockOptionImage.cellMenuColor
        case .style:
            return .EditingToolbar.style
        }
    }
}
