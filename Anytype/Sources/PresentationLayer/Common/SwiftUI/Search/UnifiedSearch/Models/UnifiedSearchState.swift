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

    var whatBucket: UnifiedSearchKindBucket? {
        for token in tokens {
            if case .kind(let bucket) = token {
                return bucket
            }
        }
        return nil
    }

    var typeUniqueKey: String? {
        for token in tokens {
            if case .type(let uniqueKey) = token {
                return uniqueKey
            }
        }
        return nil
    }

    var creatorIdentity: String? {
        for token in tokens {
            if case .creator(let identity) = token {
                return identity
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
            // Global-only buckets drop when entering a space scope
            if let bucket = whatBucket, bucket.isGlobalOnly {
                removeToken(.kind(bucket))
            }
        } else {
            tokens.removeAll { $0.group == .scope }
        }
    }
}
