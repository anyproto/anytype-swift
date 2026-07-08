import Foundation
import Factory

@MainActor
protocol BlockIdentitySwapStorageProtocol: AnyObject {
    func register(_ blockId: String)
    /// True when `ids` contains a block that just swapped identity; matches are consumed.
    func consumeSwap(in ids: [String]) -> Bool
}

/// Block ids that just replaced another block in place (virtual trailing placeholder → real
/// block, empty-block identity fork via BlockReplace).
///
/// The collection view renders an id change as an animated delete+insert — the old row fades
/// out below the new one. The editor consumes these ids to apply the swap snapshot without
/// animation, so the swap is invisible.
///
/// Ids are normally consumed on the very next update batch. `consumeSwap` may never see one
/// (the editor tears down before the create/replace event round-trips), so registration is
/// bounded: past `capacity` the oldest still-pending id is evicted. Eviction only ever
/// discards ids that were never consumed, so it cannot affect visible behavior.
@MainActor
final class BlockIdentitySwapStorage: BlockIdentitySwapStorageProtocol {
    private let capacity = 64
    private var pendingBlockIds = Set<String>()
    private var order = [String]()

    func register(_ blockId: String) {
        guard pendingBlockIds.insert(blockId).inserted else { return }
        order.append(blockId)
        if order.count > capacity {
            let evicted = order.removeFirst()
            pendingBlockIds.remove(evicted)
        }
    }

    func consumeSwap(in ids: [String]) -> Bool {
        let matched = pendingBlockIds.intersection(ids)
        guard !matched.isEmpty else { return false }
        pendingBlockIds.subtract(matched)
        order.removeAll { matched.contains($0) }
        return true
    }
}

extension Container {
    var blockIdentitySwapStorage: Factory<any BlockIdentitySwapStorageProtocol> {
        self { BlockIdentitySwapStorage() }.singleton
    }
}
