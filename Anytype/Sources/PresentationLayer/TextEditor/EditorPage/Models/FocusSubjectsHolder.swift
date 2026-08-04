import Services
import Combine

final class FocusSubjectsHolder {
    private var blocksFocusSubjects = Dictionary<String, PassthroughSubject<BlockFocusPosition, Never>>()

    func focusSubject(for blockId: String) -> PassthroughSubject<BlockFocusPosition, Never> {
        if let focusSubject = blocksFocusSubjects[blockId] {
            return focusSubject
        }

        let focusSubject = PassthroughSubject<BlockFocusPosition, Never>()
        blocksFocusSubjects[blockId] = focusSubject

        return focusSubject
    }

    /// After an in-place identity rebind the row keeps its subject: focus requests addressed
    /// to the new block id must reach the cell that subscribed under the old one. A subject
    /// already handed out for the new id stays — overwriting it would orphan its subscriber.
    func alias(oldId: String, newId: String) {
        guard blocksFocusSubjects[newId] == nil else { return }
        blocksFocusSubjects[newId] = focusSubject(for: oldId)
    }

    /// Reverses `alias` when undo dissolved the identity rebind that created it. Removes the
    /// entry only while it still is the old id's subject — an independently created subject
    /// for that id keeps its subscribers.
    func removeAlias(oldId: String, newId: String) {
        guard blocksFocusSubjects[newId] === blocksFocusSubjects[oldId] else { return }
        blocksFocusSubjects.removeValue(forKey: newId)
    }
}
