import UIKit

enum BlocksOptionItem: CaseIterable, Comparable {
    case delete
    // -- Unique options. Start
    case download
    case style
    case preview
    case openObject
    // -- Unique options. End
    case paste
    case copy
    case duplicate
    case addBlockBelow
    case move
    case moveTo
    case turnInto
}

extension BlocksOptionItem {
    private typealias BlockOptionImage = ImageAsset.TextEditor.BlocksOption

    var imageAsset: ImageAsset {
        switch self {
        case .style:
            return .EditingToolbar.style
        case .delete:
            return BlockOptionImage.delete
        case .addBlockBelow:
            return BlockOptionImage.addBelow
        case .duplicate:
            return BlockOptionImage.duplicate
        case .turnInto:
            return BlockOptionImage.turnIntoObject
        case .moveTo:
            return BlockOptionImage.moveTo
        case .move:
            return BlockOptionImage.move
        case .download:
            return BlockOptionImage.download
        case .openObject:
            return BlockOptionImage.openToEdit
        case .paste:
            return BlockOptionImage.paste
        case .copy:
            return BlockOptionImage.copy
        case .preview:
            return BlockOptionImage.view
        }
    }

    var title: String {
        switch self {
        case .style:
            return Loc.style
        case .delete:
            return Loc.delete
        case .addBlockBelow:
            return Loc.addBelow
        case .duplicate:
            return Loc.duplicate
        case .turnInto:
            return Loc.turnInto
        case .moveTo:
            return Loc.moveTo
        case .move:
            return Loc.move
        case .download:
            return Loc.download
        case .openObject:
            return Loc.openObject
        case .paste:
            return Loc.paste
        case .copy:
            return Loc.copy
        case .preview:
            return Loc.preview
        }
    }

    var analyticsEventValue: String {
        switch self {
        case .style:
            return "Style"
        case .delete:
            return "Delete"
        case .addBlockBelow:
            return "AddBelow"
        case .duplicate:
            return "Duplicate"
        case .turnInto:
            return "TurnInto"
        case .moveTo:
            return "MoveTo"
        case .move:
            return "Move"
        case .download:
            return "Download"
        case .openObject:
            return "OpenObject"
        case .paste:
            return "Paste"
        case .copy:
            return "Copy"
        case .preview:
            return "Preview"
        }
    }
}
