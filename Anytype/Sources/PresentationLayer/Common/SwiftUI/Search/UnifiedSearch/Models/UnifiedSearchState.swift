import Foundation

struct UnifiedSearchState: Equatable, Hashable, Codable {
    var searchText = ""
    var tokens: [UnifiedSearchToken] = []

    // nil = global (vault-wide) search
    var spaceScopeId: String? {
        for token in tokens {
            if case .space(let spaceId) = token {
                return spaceId
            }
        }
        return nil
    }

    mutating func addToken(_ token: UnifiedSearchToken) {
        if let index = tokens.firstIndex(where: { $0.group == token.group }) {
            tokens[index] = token
        } else {
            tokens.append(token)
        }
    }

    mutating func removeToken(_ token: UnifiedSearchToken) {
        tokens.removeAll { $0 == token }
    }

    // The entry point always overrides the scope slot on open: in-space entry
    // seeds the current space, vault entry strips it.
    mutating func setSpaceScope(_ spaceId: String?) {
        if let spaceId {
            addToken(.space(spaceId: spaceId))
        } else {
            tokens.removeAll { $0.group == .scope }
        }
    }
}
