import Foundation

// The empty browse's recency order - which date sorts and buckets the list
enum UnifiedSearchBrowseSort: String, Equatable, Hashable, Codable {
    case edited
    case created

    var title: String {
        switch self {
        case .edited: Loc.UnifiedSearch.Sort.edited
        case .created: Loc.UnifiedSearch.Sort.created
        }
    }
}

struct UnifiedSearchState: Equatable, Hashable, Codable {
    var searchText = ""
    var tokens: [UnifiedSearchToken] = []
    var browseSort: UnifiedSearchBrowseSort = .edited

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

    var focusedTypeKey: String? {
        for token in tokens {
            if case .typeFocus(let uniqueKey) = token {
                return uniqueKey
            }
        }
        return nil
    }

    var focusedPersonIdentity: String? {
        for token in tokens {
            if case .personFocus(let identity) = token {
                return identity
            }
        }
        return nil
    }

    mutating func addToken(_ token: UnifiedSearchToken) {
        // Yield rules: a creator filter cannot combine with a person focus
        // (participants are not authored); a scope means "search in this
        // Channel", not "list members in it" - the focus yields; a type focus
        // narrows to the plain type filter; global-only buckets drop.
        if case .creator = token {
            tokens.removeAll { if case .personFocus = $0 { true } else { false } }
        }
        if case .space = token {
            tokens = tokens.compactMap { existing in
                switch existing {
                case .personFocus:
                    return nil
                case .typeFocus(let uniqueKey):
                    return .type(uniqueKey: uniqueKey)
                case .kind(let bucket) where bucket.isGlobalOnly:
                    return nil
                default:
                    return existing
                }
            }
        }

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
    // seeds the current space, vault entry strips it. The yield rules
    // (global-only buckets, focuses) live in addToken.
    mutating func setSpaceScope(_ spaceId: String?) {
        if let spaceId {
            addToken(.space(spaceId: spaceId))
        } else {
            tokens.removeAll { $0.group == .scope }
        }
    }
}
