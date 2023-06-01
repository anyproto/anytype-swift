import UIKit

private typealias L10n = Loc.SimpleTableMenu.Item

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
            return .X32.remove
        case .color:
            return .X32.color
        case .style:
            return .X32.style
        case .clearStyle:
            return .X32.clear
        }
    }
}

enum SimpleTableColumnMenuItem: CaseIterable {
    case insertLeft
    case insertRight
    case moveLeft
    case moveRight
    case delete
    // Paste
    // Copy
    case duplicate
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
            return .X32.AddColumn.left
        case .insertRight:
            return .X32.AddColumn.right
        case .moveLeft:
            return .X32.MoveColumn.left
        case .moveRight:
            return .X32.MoveColumn.right
        case .duplicate:
            return .X32.duplicate
        case .delete:
            return .X32.delete
        case .clearContents:
            return .X32.remove
        case .sort:
            return .X32.sort
        case .color:
            return .X32.color
        case .style:
            return .X32.style
        }
    }
}

enum SimpleTableRowMenuItem: CaseIterable {
    case insertAbove
    case insertBelow
    case moveDown
    case moveUp
    case delete
    // Paste
    // Copy
    case duplicate
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
            return .X32.AddColumn.above
        case .insertBelow:
            return .X32.AddColumn.below
        case .moveUp:
            return .X32.MoveColumn.up
        case .moveDown:
            return .X32.MoveColumn.down
        case .duplicate:
            return .X32.duplicate
        case .delete:
            return .X32.delete
        case .clearContents:
            return .X32.remove
        case .color:
            return .X32.color
        case .style:
            return .X32.style
        }
    }
}
