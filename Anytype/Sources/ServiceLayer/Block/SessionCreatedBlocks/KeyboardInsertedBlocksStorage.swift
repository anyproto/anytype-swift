import Foundation
import Factory

@MainActor
protocol KeyboardInsertedBlocksStorageProtocol: AnyObject {
    func register(blockId: String)
    /// Registered ids appearing in `ids`; matches are consumed.
    func consume(in ids: [String]) -> [String]
}

/// Block ids created at the user's caret by a keyboard Enter, pending their first render.
///
/// These rows look right with UIKit's native animated insert and caret move, except at the
/// bottom edge where the insert competes with the caret-visibility scroll and renders as a
/// jump. The editor consumes these ids to apply that snapshot without animation and to move
/// the caret into the created row within the same render commit.
///
/// Ids are normally consumed on the very next update batch. `consume` may never see one
/// (the editor tears down before the create event round-trips), so registration is bounded:
/// past `capacity` the oldest still-pending id is evicted. Eviction only ever discards ids
/// that were never consumed, so it cannot affect visible behavior.
@MainActor
final class KeyboardInsertedBlocksStorage: KeyboardInsertedBlocksStorageProtocol {
    private let capacity = 64
    private var pendingIds = [String]()

    func register(blockId: String) {
        guard !pendingIds.contains(blockId) else { return }
        pendingIds.append(blockId)
        if pendingIds.count > capacity {
            pendingIds.removeFirst()
        }
    }

    func consume(in ids: [String]) -> [String] {
        let idsSet = Set(ids)
        let matches = pendingIds.filter { idsSet.contains($0) }
        guard !matches.isEmpty else { return [] }
        pendingIds.removeAll { idsSet.contains($0) }
        return matches
    }
}

extension Container {
    // A process-wide singleton (like its predecessor): block ids are globally unique, so
    // entries from different editor pages cannot collide, and the capacity bound only
    // affects animation choice, never correctness.
    var keyboardInsertedBlocksStorage: Factory<any KeyboardInsertedBlocksStorageProtocol> {
        self { KeyboardInsertedBlocksStorage() }.singleton
    }
}
