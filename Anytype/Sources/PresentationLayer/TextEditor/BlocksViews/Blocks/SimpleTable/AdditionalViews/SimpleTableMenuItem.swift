import Foundation

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
}
