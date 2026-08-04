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

    /// The empty-block identity fork changes a live row's block id in place while its cell
    /// keeps listening to the subject created under the old id. Moving the subject keeps
    /// id-keyed focus sends (merge, restore) reaching that cell.
    func rekeySubject(from oldBlockId: String, to newBlockId: String) {
        guard let subject = blocksFocusSubjects.removeValue(forKey: oldBlockId) else { return }
        blocksFocusSubjects[newBlockId] = subject
    }
}
