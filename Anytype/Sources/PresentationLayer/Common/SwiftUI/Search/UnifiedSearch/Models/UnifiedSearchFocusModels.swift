import Foundation
import Services

// A row of a focused listing: the focused type's or person's instance in one
// space. A type instance's primary action opens it; its trailing action filters.
// Person instances filter (creator + that space) from either action.
struct UnifiedSearchFocusRow: Identifiable, Hashable {
    enum Kind: Hashable {
        case typeInstance
        case personInstance
        case oneToOneChannel
    }

    let kind: Kind
    let objectId: String
    let spaceId: String
    let title: String
    let icon: Icon
    let caption: String?

    var id: String { objectId + spaceId }
}

// The way back out wide from a focused listing - the all-Channels filter the
// grouped row's drill offered before focusing, plus the 1:1 create verb
enum UnifiedSearchFocusSuggestion: Identifiable, Hashable {
    case searchTypeEverywhere(uniqueKey: String, name: String)
    case searchCreatorEverywhere(identity: String, name: String)
    case createOneToOne(identity: String)

    var id: String {
        switch self {
        case .searchTypeEverywhere(let uniqueKey, _): "type-all:\(uniqueKey)"
        case .searchCreatorEverywhere(let identity, _): "creator-all:\(identity)"
        case .createOneToOne(let identity): "create-1to1:\(identity)"
        }
    }

    var title: String {
        switch self {
        case .searchTypeEverywhere(_, let name):
            Loc.UnifiedSearch.Focus.searchTypeAll(name)
        case .searchCreatorEverywhere(_, let name):
            Loc.UnifiedSearch.Focus.searchCreatorAll(name)
        case .createOneToOne:
            Loc.UnifiedSearch.Person.createOneToOne
        }
    }
}

// Restores the pre-drill search when the drill-added token is removed - the
// undo for row-added tokens. Session-only.
struct UnifiedSearchSnapshot {
    var tokens: [UnifiedSearchToken]
    var searchText: String
    // Removing this token pops the snapshot
    let ownerTokenId: String
    // Everything the owning gesture added (a focused-person pick adds creator +
    // scope at once) - the undo removes all of it, keeping later additions
    let gestureTokenIds: Set<String>
}
