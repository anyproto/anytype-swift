import Foundation
import Factory

struct BlockIdentitySwap: Equatable {
    let newBlockId: String
    /// Id of the row the new block replaced in place — a document block (empty-block fork) or
    /// the virtual trailing placeholder's local id. Nil for the placeholder when
    /// stableRowIdentityOnFork is off (its row removal is then session-managed) and for
    /// Enter-created rows, which replace nothing.
    let oldBlockId: String?
    /// True for rows created by a keyboard Enter. Unlike identity swaps — which must always
    /// render unanimated — these look right with UIKit's native animated insert, except at the
    /// bottom edge where the insert competes with the caret-visibility scroll; the editor
    /// applies the unanimated one-commit pipeline only there.
    let isKeyboardInsert: Bool
}

@MainActor
protocol BlockIdentitySwapStorageProtocol: AnyObject {
    func register(newBlockId: String, replacingBlockId: String?, keyboardInsert: Bool)
    /// Swaps whose new block id appears in `ids`; matches are consumed.
    func consumeSwaps(in ids: [String]) -> [BlockIdentitySwap]
}

/// Block ids whose arrival must render without the animated insert: blocks that just replaced
/// another block in place (virtual trailing placeholder → real block, empty-block identity
/// fork via BlockReplace) and rows created at the user's caret by a keyboard Enter.
///
/// The collection view renders an id change as an animated delete+insert — the old row fades
/// out below the new one — and an Enter-created row as a slow expansion over the row below.
/// The editor consumes these ids to apply the snapshot without animation. A consumed swap's
/// `oldBlockId` lets the editor rebind the old row to the new id in place
/// (stableRowIdentityOnFork); in the fallback pipeline it instead keeps the old — still
/// focused — row alive until the new cell takes the keyboard over.
///
/// Ids are normally consumed on the very next update batch. `consumeSwaps` may never see one
/// (the editor tears down before the create/replace event round-trips), so registration is
/// bounded: past `capacity` the oldest still-pending id is evicted. Eviction only ever
/// discards ids that were never consumed, so it cannot affect visible behavior.
@MainActor
final class BlockIdentitySwapStorage: BlockIdentitySwapStorageProtocol {
    private let capacity = 64
    private var pendingSwaps = [String: BlockIdentitySwap]()
    private var order = [String]()

    func register(newBlockId: String, replacingBlockId: String?, keyboardInsert: Bool) {
        guard pendingSwaps[newBlockId] == nil else { return }
        pendingSwaps[newBlockId] = BlockIdentitySwap(newBlockId: newBlockId, oldBlockId: replacingBlockId, isKeyboardInsert: keyboardInsert)
        order.append(newBlockId)
        if order.count > capacity {
            let evicted = order.removeFirst()
            pendingSwaps.removeValue(forKey: evicted)
        }
    }

    func consumeSwaps(in ids: [String]) -> [BlockIdentitySwap] {
        let swaps = ids.compactMap { pendingSwaps[$0] }
        guard !swaps.isEmpty else { return [] }
        for swap in swaps {
            pendingSwaps.removeValue(forKey: swap.newBlockId)
        }
        order.removeAll { pendingSwaps[$0] == nil }
        return swaps
    }
}

extension Container {
    var blockIdentitySwapStorage: Factory<any BlockIdentitySwapStorageProtocol> {
        self { BlockIdentitySwapStorage() }.singleton
    }
}
