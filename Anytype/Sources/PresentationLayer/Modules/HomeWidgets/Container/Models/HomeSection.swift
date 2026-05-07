import Foundation

enum HomeSection: String, CaseIterable, Codable, Sendable {
    case unread
    case pinned
    case myFavorites
    case recentlyEdited
    case objects
    case bin

    var analyticsId: String {
        switch self {
        case .unread: "Unread"
        case .pinned: "Pinned"
        case .myFavorites: "MyFavorites"
        case .recentlyEdited: "RecentlyEdited"
        case .objects: "Objects"
        case .bin: "Bin"
        }
    }

    // UserDefaults key for the section's expand/collapse state. `nil` for sections
    // without a persistent expand state (Pinned and Bin). String values must stay
    // stable so existing user state survives.
    var expandedStorageId: String? {
        switch self {
        case .unread:         "HomeUnreadSection"
        case .pinned:          nil
        case .myFavorites:    "HomeMyFavoritesSection"
        case .recentlyEdited: "HomeRecentlyEditedSection"
        case .objects:        "HomeObjectTypeSection"
        case .bin:             nil
        }
    }
}

struct HomeSectionsConfiguration: Codable, Equatable, Sendable {
    /// Visible sections in render order. Sections not listed are hidden.
    let visibleSections: [HomeSection]

    static let `default` = HomeSectionsConfiguration(
        visibleSections: [.pinned, .unread, .myFavorites, .recentlyEdited, .objects, .bin]
    )
}
