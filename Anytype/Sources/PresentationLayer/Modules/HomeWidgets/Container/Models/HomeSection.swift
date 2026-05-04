import Foundation

enum HomeSection: String, CaseIterable, Codable, Sendable {
    case unread
    case pinned
    case myFavorites
    case recentlyEdited
    case objects
    case bin
}

struct HomeSectionsConfiguration: Codable, Equatable, Sendable {
    /// Visible sections in render order. Sections not listed are hidden.
    let visibleSections: [HomeSection]

    static let `default` = HomeSectionsConfiguration(
        visibleSections: [.pinned, .unread, .myFavorites, .recentlyEdited, .objects, .bin]
    )
}
