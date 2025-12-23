import Foundation

struct SpaceStartWithData: Identifiable, Hashable {
    let spaceId: String

    var id: String { spaceId }
}

enum SpaceStartWithOption {
    case page
    case chat
    case widgets
}
