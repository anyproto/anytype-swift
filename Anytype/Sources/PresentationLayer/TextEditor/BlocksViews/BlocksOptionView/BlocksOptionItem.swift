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
            return "Style".localized
        case .delete:
            return "Delete".localized
        case .addBlockBelow:
            return "Add below".localized
        case .duplicate:
            return "Duplicate".localized
        case .turnInto:
            return "Turn into".localized
        case .moveTo:
            return "Move to".localized
        case .move:
            return "Move".localized
        case .download:
            return "Download".localized
        case .paste:
            return "Paste".localized
        case .copy:
            return "Copy".localized
        case .preview:
            return "Preview".localized
        }
    }
}
