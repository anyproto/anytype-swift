import Foundation

/// Block ids created by this app session.
///
/// The trailing placeholder may focus-reuse an empty last block only when this session created it.
/// Reusing a foreign empty block (an old client, another user) makes concurrent cursors from
/// different clients converge on the same block id, and whole-value last-writer-wins text sync
/// then silently drops one user's input.
@MainActor
final class SessionCreatedBlockIdsStorage {
    static let shared = SessionCreatedBlockIdsStorage()

    private var ids = Set<String>()

    private init() {}

    func register(_ blockId: String) {
        ids.insert(blockId)
    }

    func contains(_ blockId: String) -> Bool {
        ids.contains(blockId)
    }
}
