import UIKit

enum BlocksOptionItem: CaseIterable, Comparable {
    case delete
    // -- Unique options. Start
    case download
    case style
    case preview
    case openObject
    case openSource
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
    
    var imageAsset: ImageAsset {
        switch self {
        case .style:
            return .X32.style
        case .delete:
            return .X32.delete
        case .addBlockBelow:
            return .X32.addBelow
        case .duplicate:
            return .X32.duplicate
        case .turnInto:
            return .X32.turnIntoObject
        case .moveTo:
            return .X32.moveTo
        case .move:
            return .X32.move
        case .download:
            return .X32.download
        case .openObject:
            return .X32.openAsObject
        case .openSource:
            return .X32.openAsObject
        case .paste:
            return .X32.paste
        case .copy:
            return .X32.copy
        case .preview:
            return .X32.View.view
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
            return Loc.intoObject
        case .moveTo:
            return Loc.moveTo
        case .move:
            return Loc.move
        case .download:
            return Loc.download
        case .openObject:
            return Loc.openObject
        case .openSource:
            return Loc.openSource
        case .paste:
            return Loc.paste
        case .copy:
            return Loc.copy
        case .preview:
            return Loc.view
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
        case .openSource:
            return "OpenSource"
        case .paste:
            return "Paste"
        case .copy:
            return "Copy"
        case .preview:
            return "Preview"
        }
    }
}
