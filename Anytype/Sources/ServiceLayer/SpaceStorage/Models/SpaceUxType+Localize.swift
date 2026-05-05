import Foundation
import Services

extension SpaceType {
    var name: String {
        switch self {
        case .chat:
            return Loc.Spaces.UxType.Chat.title
        case .regular:
            return Loc.Spaces.UxType.Space.title
        case .oneToOne:
            return Loc.Spaces.UxType.OneToOne.title
        case .tech, .unknown, .UNRECOGNIZED:
            return ""
        }
    }
}
