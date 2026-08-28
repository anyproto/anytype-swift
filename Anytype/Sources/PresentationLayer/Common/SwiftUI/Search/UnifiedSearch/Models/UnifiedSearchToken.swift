import Foundation
import Services

// A filter applied to the unified search, rendered as a removable pill inside the
// search input. At most one token per group; adding another replaces it in place.
// Persisted by value - display data (space name, type name, person name) is
// resolved from stores on restore, and unresolvable tokens are dropped silently.
enum UnifiedSearchToken: Equatable, Hashable, Codable, Identifiable {
    case space(spaceId: String)
    case kind(UnifiedSearchKindBucket)
    case type(uniqueKey: String)
    case creator(identity: String)

    enum Group: Equatable {
        case scope
        case what
        case who
    }

    var id: String {
        switch self {
        case .space(let spaceId):
            "space:\(spaceId)"
        case .kind(let bucket):
            "kind:\(bucket.rawValue)"
        case .type(let uniqueKey):
            "type:\(uniqueKey)"
        case .creator(let identity):
            "creator:\(identity)"
        }
    }

    var group: Group {
        switch self {
        case .space:
            .scope
        case .kind, .type:
            .what
        case .creator:
            .who
        }
    }
}

// A layout bucket - the coarse "what" filter. A specific type is a narrower
// version of a bucket and occupies the same token slot.
enum UnifiedSearchKindBucket: String, Equatable, Codable, CaseIterable {
    case messages
    case media
    case pages
    case bookmarks
    case collections
    case queries
    case channels

    // Per-space types replace the global buckets inside a space scope
    var isGlobalOnly: Bool {
        switch self {
        case .messages, .media:
            false
        case .pages, .bookmarks, .collections, .queries, .channels:
            true
        }
    }

    var layouts: [DetailsLayout] {
        switch self {
        case .media:
            DetailsLayout.mediaLayouts
        case .pages:
            DetailsLayout.editorLayouts
        case .bookmarks:
            [.bookmark]
        case .collections:
            [.collection]
        case .queries:
            [.set]
        case .messages, .channels:
            [] // messages use the Chat.Search loader; channels the in-memory space list
        }
    }

    var title: String {
        switch self {
        case .messages:
            Loc.UnifiedSearch.Chip.messages
        case .media:
            Loc.media
        case .pages:
            Loc.pages
        case .bookmarks:
            Loc.bookmarks
        case .collections:
            Loc.collections
        case .queries:
            Loc.sets
        case .channels:
            Loc.UnifiedSearch.Section.channels
        }
    }
}
