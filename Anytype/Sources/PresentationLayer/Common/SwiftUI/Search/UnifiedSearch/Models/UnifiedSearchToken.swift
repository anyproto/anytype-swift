import Foundation
import Services

// A filter applied to the unified search, rendered as a removable pill inside the
// search input. At most one token per group; adding another replaces it in place.
// Persisted by value - display data (space name, type name, person name) is
// resolved from stores on restore, and unresolvable tokens are dropped silently.
enum UnifiedSearchToken: Equatable, Hashable, Codable, Identifiable {
    case space(spaceId: String)
    case kind(UnifiedSearchKindBucket)
    // One chat's messages - a narrowed Messages token (in-chat search entry).
    // Removing it widens back to kind(.messages). Carries its space so the
    // filter outlives the scope token and yields only to a different space.
    case chat(chatId: String, spaceId: String)
    case type(uniqueKey: String)
    case creator(identity: String)
    // Focus (a grouped lead row was tapped): the list shows the focused thing's
    // per-space instances instead of filtered objects. Occupies the what slot.
    case typeFocus(uniqueKey: String)
    case personFocus(identity: String)

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
        case .chat(let chatId, _):
            "chat:\(chatId)"
        case .type(let uniqueKey):
            "type:\(uniqueKey)"
        case .creator(let identity):
            "creator:\(identity)"
        case .typeFocus(let uniqueKey):
            "typeFocus:\(uniqueKey)"
        case .personFocus(let identity):
            "personFocus:\(identity)"
        }
    }

    var group: Group {
        switch self {
        case .space:
            .scope
        case .kind, .chat, .type, .typeFocus, .personFocus:
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
    case chats
    case channels

    // Per-space types replace the global buckets inside a space scope
    var isGlobalOnly: Bool {
        switch self {
        case .messages, .media:
            false
        case .pages, .bookmarks, .collections, .queries, .chats, .channels:
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
        case .chats:
            [.chatDerived]
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
        case .chats:
            Loc.UnifiedSearch.Chip.chats
        case .channels:
            Loc.UnifiedSearch.Section.channels
        }
    }
}
