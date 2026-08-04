import Foundation

/// Stable editor-row identities across in-place block id changes, scoped to one editor page.
///
/// The empty-block identity fork (BlockReplace) and the trailing placeholder materialization
/// (BlockCreate) swap a visible row's block id for a middleware-generated one. Diffable item
/// identity derives from the block id, so the id change would render as delete+insert: the
/// focused cell and its UITextView die, the keyboard input session restarts, and autocorrect
/// loses the just-typed word prefix. Aliasing the new id to the replaced row keeps the row's
/// identity constant, so the swap diffs as an empty change and the live cell — with its input
/// session — survives. See EditorPageViewModel.rebindIdentitySwaps.
///
/// Entries store the immediately replaced id, not the resolved root: undo restores exactly the
/// replaced block, and detecting that requires the direct pair (see
/// rebindUndoneIdentitySwaps). `rowId(for:)` resolves chains (virtual placeholder → created
/// block → later fork) transitively; acyclicity holds because a new id is a fresh
/// middleware-generated id aliased at most once.
@MainActor
final class BlockRowIdentityMap {
    private var replacedIdByNewId = [String: String]()

    /// False when the new id is already aliased — the caller must not rebind on top of an
    /// existing registration: a live model's frozen `rowIdentity` would disagree with what
    /// later rebuilds resolve.
    func alias(newBlockId: String, toRowOf oldBlockId: String) -> Bool {
        guard replacedIdByNewId[newBlockId] == nil else { return false }
        replacedIdByNewId[newBlockId] = oldBlockId
        return true
    }

    func removeAlias(newBlockId: String) {
        replacedIdByNewId.removeValue(forKey: newBlockId)
    }

    func rowId(for blockId: String) -> String {
        var rowId = blockId
        while let replaced = replacedIdByNewId[rowId] {
            rowId = replaced
        }
        return rowId
    }

    /// Pairs whose new id is gone while the id it replaced is present again — undo restored
    /// the replaced block. `presentIds` is the document's current flattened id set.
    func undoneAliases(presentIds: Set<String>) -> [(newBlockId: String, replacedBlockId: String)] {
        replacedIdByNewId
            .filter { !presentIds.contains($0.key) && presentIds.contains($0.value) }
            .map { ($0.key, $0.value) }
    }
}
