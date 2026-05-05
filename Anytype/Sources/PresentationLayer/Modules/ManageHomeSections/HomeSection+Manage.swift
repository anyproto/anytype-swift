import Foundation

extension HomeSection {
    var isLocked: Bool {
        switch self {
        case .pinned, .unread: return true
        case .myFavorites, .recentlyEdited, .objects, .bin: return false
        }
    }

    var localizedTitle: String {
        switch self {
        case .pinned:         return Loc.homeAndPinned
        case .unread:         return Loc.unread
        case .myFavorites:    return Loc.myFavorites
        case .recentlyEdited: return Loc.recentlyEdited
        case .objects:        return Loc.objects
        case .bin:            return Loc.bin
        }
    }
}
