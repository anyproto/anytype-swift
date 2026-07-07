import Foundation

/// Block ids that just replaced another block in place (virtual trailing placeholder → real
/// block, empty-block identity fork via BlockReplace).
///
/// The collection view renders an id change as an animated delete+insert — the old row fades
/// out below the new one. The editor consumes these ids to apply the swap snapshot without
/// animation, so the swap is invisible.
@MainActor
final class BlockIdentitySwapStorage {
    static let shared = BlockIdentitySwapStorage()

    private var pendingBlockIds = Set<String>()

    private init() {}

    func register(_ blockId: String) {
        pendingBlockIds.insert(blockId)
    }

    /// True when `ids` contains a block that just swapped identity; matches are consumed.
    func consumeSwap(in ids: [String]) -> Bool {
        let matched = pendingBlockIds.intersection(ids)
        guard !matched.isEmpty else { return false }
        pendingBlockIds.subtract(matched)
        return true
    }
}
