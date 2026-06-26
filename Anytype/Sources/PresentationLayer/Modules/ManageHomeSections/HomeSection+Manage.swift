import Foundation

extension HomeSection {
    static let lockedSections: [HomeSection] = [.pinned, .unread]

    var isLocked: Bool {
        Self.lockedSections.contains(self)
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
