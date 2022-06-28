import UIKit

enum BlocksOptionItem: CaseIterable, Comparable {
    case paste
    case copy
    case preview
    case style
    case download
    case delete
    case addBlockBelow
    case duplicate
    case turnInto
    case move
    case moveTo
}

extension BlocksOptionItem {
    private typealias BlockOptionImage = UIImage.editor.BlockOption

    var image: UIImage {
        switch self {
        case .style:
            return UIImage.edititngToolbar.style
        case .delete:
            return BlockOptionImage.delete
        case .addBlockBelow:
            return BlockOptionImage.addBelow
        case .duplicate:
            return BlockOptionImage.duplicate
        case .turnInto:
            return BlockOptionImage.turnInto
        case .moveTo:
            return BlockOptionImage.moveTo
        case .move:
            return BlockOptionImage.move
        case .download:
            return BlockOptionImage.download
        case .paste:
            return BlockOptionImage.paste
        case .copy:
            return BlockOptionImage.copy
        case .preview:
            return BlockOptionImage.preview
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
        case .paste:
            return Loc.paste
        case .copy:
            return Loc.copy
        case .preview:
            return Loc.preview
        }
    }
}
