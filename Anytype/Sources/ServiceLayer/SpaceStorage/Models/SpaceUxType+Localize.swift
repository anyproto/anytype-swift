import Foundation
import Services

extension SpaceUxType {
    var name: String {
        switch self {
        case .chat:
            return Loc.Spaces.UxType.Chat.title
        case .data:
            return Loc.Spaces.UxType.Space.title
        case .stream:
            return Loc.Spaces.UxType.Stream.title
        case .UNRECOGNIZED:
            return ""
        }
    }
}
