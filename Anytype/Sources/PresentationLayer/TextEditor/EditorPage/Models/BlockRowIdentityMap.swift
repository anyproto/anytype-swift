import Foundation

/// Stable editor-row identities across in-place block id changes, scoped to one editor page.
///
/// The empty-block identity fork (BlockReplace) swaps a visible row's block id for a fresh,
/// client-minted one. Diffable item identity derives from the block id, so the id change
/// would render as delete+insert: the focused cell and its UITextView die, the keyboard
/// input session restarts, and autocorrect loses the just-typed word prefix. Aliasing the
/// new id to the replaced row keeps the row's identity constant, so the swap diffs as an
/// empty change and the live cell — with its input session — survives.
///
/// Entries store the immediately replaced id, not the resolved root: undo restores exactly
/// the replaced block, and detecting that requires the direct pair (see `undoneAliases`).
/// `rowId(for:)` and `latestId(for:)` resolve chains (fork → undo → fresh fork) transitively;
/// acyclicity holds because every new id is a freshly minted id aliased at most once.
///
/// Deliberately unbounded: an alias must outlive its fork for the page's lifetime, because
/// any later rebuild of the block resolves its row identity through it. Entries are two
/// small strings per first-fill of an empty block — page-scoped and reclaimed on close.
@MainActor
final class BlockRowIdentityMap {
    private struct Alias {
        let replacedId: String
        /// Whether the new id has been seen in the document's flattened ids. Before the
        /// replace event applies, the new id's absence means "not landed yet", not "undone".
        var applied = false
    }

    private var aliasByNewId = [String: Alias]()
    private var newIdByReplacedId = [String: String]()

    /// False when either id already takes part in a pair in the same role — the caller must
    /// not rebind on top of an existing registration: a live model's frozen `rowIdentity`
    /// would disagree with what later rebuilds resolve.
    func register(newBlockId: String, replacing replacedBlockId: String) -> Bool {
        guard newBlockId != replacedBlockId else { return false }
        guard aliasByNewId[newBlockId] == nil, newIdByReplacedId[replacedBlockId] == nil else { return false }
        aliasByNewId[newBlockId] = Alias(replacedId: replacedBlockId)
        newIdByReplacedId[replacedBlockId] = newBlockId
        return true
    }

    func removeAlias(newBlockId: String) {
        guard let alias = aliasByNewId.removeValue(forKey: newBlockId) else { return }
        newIdByReplacedId.removeValue(forKey: alias.replacedId)
    }

    /// The row identity for `blockId`: the id of the row it (transitively) replaced.
    func rowId(for blockId: String) -> String {
        var rowId = blockId
        while let alias = aliasByNewId[rowId] {
            rowId = alias.replacedId
        }
        return rowId
    }

    /// The newest id in `blockId`'s replacement chain. A just-forked block can still be
    /// emitted or reset under its replaced id while the replace event is in flight; builds
    /// resolve such stale ids forward to the block that lives on the row now.
    func latestId(for blockId: String) -> String {
        var latestId = blockId
        while let newerId = newIdByReplacedId[latestId] {
            latestId = newerId
        }
        return latestId
    }

    /// Pairs whose new id disappeared after having been seen applied while the replaced id
    /// is present again — undo restored the replaced block. Also records first-seen
    /// application for ids in `presentIds`, so a pair whose replace event has not landed yet
    /// is never mistaken for an undone one.
    ///
    /// Known gap, accepted: if the replace event and its undo were ever coalesced into a
    /// single ids emission, the new id would never be seen applied and the undo would go
    /// undetected. Undo is human-initiated on committed, rendered state, so the replace
    /// emission always precedes it by orders of magnitude more than one event batch.
    func undoneAliases(presentIds: Set<String>) -> [(newBlockId: String, replacedBlockId: String)] {
        var undone = [(newBlockId: String, replacedBlockId: String)]()
        for (newId, alias) in aliasByNewId {
            if presentIds.contains(newId) {
                if !alias.applied {
                    aliasByNewId[newId]?.applied = true
                }
            } else if alias.applied, presentIds.contains(alias.replacedId) {
                undone.append((newId, alias.replacedId))
            }
        }
        return undone
    }
}
