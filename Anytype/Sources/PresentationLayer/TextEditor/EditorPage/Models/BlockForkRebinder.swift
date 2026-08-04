import Foundation
import UIKit
import Services

/// Applies the empty-block identity fork to the live editor state — and takes it back.
///
/// With the replacement id minted client-side, the fork is a synchronous, local operation:
/// `rebind` runs in the same turn as the keystroke that initiated the fork, before the
/// BlockReplace RPC is sent, so no event or snapshot apply can observe an intermediate
/// state. The row's diffable identity stays frozen (`TextBlockViewModel.rowIdentity`); only
/// the backing block changes underneath it.
///
/// `unbind` is the inverse, for the two ways the replaced block comes back: undo restored
/// it (detected by `rebindUndoneForks` scanning the fork aliases against the document's
/// current ids), or the replace RPC failed and the middleware never saw the new id.
@MainActor
final class BlockForkRebinder {
    private let modelsHolder: EditorMainItemModelsHolder
    private let rowIdentityMap: BlockRowIdentityMap
    private let infoContainer: any InfoContainerProtocol
    private let focusSubjectHolder: FocusSubjectsHolder
    private let cursorManager: EditorCursorManager
    private let collectionController: EditorBlockCollectionController

    init(
        modelsHolder: EditorMainItemModelsHolder,
        rowIdentityMap: BlockRowIdentityMap,
        infoContainer: some InfoContainerProtocol,
        focusSubjectHolder: FocusSubjectsHolder,
        cursorManager: EditorCursorManager,
        collectionController: EditorBlockCollectionController
    ) {
        self.modelsHolder = modelsHolder
        self.rowIdentityMap = rowIdentityMap
        self.infoContainer = infoContainer
        self.focusSubjectHolder = focusSubjectHolder
        self.cursorManager = cursorManager
        self.collectionController = collectionController
    }

    /// Rebinds the live row for `oldInfo.id` to the minted `replacement` in place. False when
    /// there is no live row to rebind (the model is not part of the editor's list — e.g. a
    /// simple-table cell) or the ids are already aliased; the caller then falls back to a
    /// pending focus for the freshly rendered row.
    func rebind(oldInfo: BlockInformation, to replacement: BlockInformation) -> Bool {
        guard let model = modelsHolder.blocksMapping[oldInfo.id] as? TextBlockViewModel else { return false }
        guard rowIdentityMap.register(newBlockId: replacement.id, replacing: oldInfo.id) else { return false }
        // The replace event carries the real info later (same id); until then the fabricated
        // replacement serves the provider subscription and any rebuild.
        infoContainer.add(replacement)
        focusSubjectHolder.rekeySubject(from: oldInfo.id, to: replacement.id)
        model.rebind(to: replacement)
        // Re-key blocksMapping to the new id, so builds during the in-flight window — which
        // resolve any chain id to the latest one — land on this model.
        modelsHolder.updateMappings()
        // Refresh the live cell: the empty diff will never reconfigure it, and its
        // configuration still carries the replaced id (drag id, leading-view key).
        // applyTextStorage skips the text-storage write while the text is identical, so the
        // keyboard input session survives this refresh. Unanimated: this targets the focused
        // cell mid-typing — a height change animating around the caret is exactly what the
        // stable row identity exists to prevent.
        UIView.performWithoutAnimation {
            collectionController.reconfigure(items: [.block(model)])
        }
        return true
    }

    /// Rebinds the row carrying `newBlockId` back to the restored `restoringBlockId` and
    /// drops the alias, so the restored block renders through its own identity again —
    /// without this the empty diff keeps the stale row on screen and routes edits to a
    /// nonexistent id.
    func unbind(newBlockId: String, restoringBlockId: String) {
        guard let model = modelsHolder.blocksMapping[newBlockId] as? TextBlockViewModel else {
            // No live row carries the forked id — nothing to rebind back; drop the alias so
            // the undo scan stops matching it.
            rowIdentityMap.removeAlias(newBlockId: newBlockId)
            return
        }
        guard modelsHolder.blocksMapping[restoringBlockId] == nil,
              let restoredInfo = infoContainer.get(id: restoringBlockId) else {
            // Keep the alias: consuming it on a failed rebind would leave the live row
            // stranded on the dead id with no way back. The undo scan retries next pass.
            return
        }
        rowIdentityMap.removeAlias(newBlockId: newBlockId)
        // The undo already removed the forked id from the container; this is a no-op kept
        // for symmetry with the fabricated-info add in rebind.
        infoContainer.remove(id: newBlockId)
        focusSubjectHolder.rekeySubject(from: newBlockId, to: restoringBlockId)
        model.rebindAfterIdentityUndo(to: restoredInfo)
        modelsHolder.updateMappings()
        if cursorManager.blockFocus?.id == newBlockId {
            cursorManager.blockFocus = nil
        }
        // The restored text differs from the typed one, so this reconfigure intentionally
        // rewrites the text storage — undo is expected to reset the typing session. The row
        // itself never leaves the snapshot: the same cell keeps first responder throughout.
        UIView.performWithoutAnimation {
            collectionController.reconfigure(items: [.block(model)])
        }
    }

    /// Inverse of `rebind` for the replace RPC failing: the middleware never saw the
    /// replacement, so — unlike the undo scan above, which may retry — this must run to
    /// completion exactly once. The alias and the fabricated info always go; the row rebinds
    /// back only when the old block still exists (it may have been deleted remotely in the
    /// meantime — the very failure that usually lands here — in which case the row simply
    /// drops out of the snapshot on the next update, carrying no live id).
    func rollbackFailedFork(replacementId: String, oldId: String) {
        rowIdentityMap.removeAlias(newBlockId: replacementId)
        infoContainer.remove(id: replacementId)
        if cursorManager.blockFocus?.id == replacementId {
            cursorManager.blockFocus = nil
        }
        guard let model = modelsHolder.blocksMapping[replacementId] as? TextBlockViewModel,
              modelsHolder.blocksMapping[oldId] == nil,
              let restoredInfo = infoContainer.get(id: oldId) else { return }
        // Rekey only where the model rebinds back — mirroring `unbind`. When the rebind
        // never happened, no subject was moved and rekeying would clobber a legitimate
        // subject under the old id; when the old block is gone, the row is about to drop
        // out of the snapshot and its subject is inert either way.
        focusSubjectHolder.rekeySubject(from: replacementId, to: oldId)
        model.rebindAfterIdentityUndo(to: restoredInfo)
        modelsHolder.updateMappings()
        UIView.performWithoutAnimation {
            collectionController.reconfigure(items: [.block(model)])
        }
    }

    /// Undo can restore a block an in-place rebind replaced: the live row then carries a
    /// deleted id while its predecessor reappears in the document's ids. Runs at the top of
    /// every update pass, before models are built against the fork chain.
    func rebindUndoneForks(presentIds: Set<String>) {
        for alias in rowIdentityMap.undoneAliases(presentIds: presentIds) {
            unbind(newBlockId: alias.newBlockId, restoringBlockId: alias.replacedBlockId)
        }
    }
}
