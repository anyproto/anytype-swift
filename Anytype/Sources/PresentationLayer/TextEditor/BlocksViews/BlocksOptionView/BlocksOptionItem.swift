import UIKit

enum BlocksOptionItem: String, CaseIterable {
    case delete
    case addBlockBelow
    case duplicate
    case turnInto
    case moveTo
}

extension BlocksOptionItem {
    private typealias BlockOptionImage = UIImage.editor.BlockOption

    var image: UIImage {
        switch self {
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
        }
    }

    var title: String {
        switch self {
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
        }
    }
}
