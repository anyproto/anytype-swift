import BlocksModels
import Combine

final class FocusSubjectsHolder { // This class should be merged somehow with EditorCursorManager
    var blocksFocusSubjects = Dictionary<BlockId, PassthroughSubject<BlockFocusPosition, Never>>()

    func setFocus(blockId: BlockId, position: BlockFocusPosition) {
        blocksFocusSubjects[blockId]?
            .send(position)
    }

    func focusSubject(for blockId: BlockId) -> PassthroughSubject<BlockFocusPosition, Never> {
        if let focusSubject = blocksFocusSubjects[blockId] {
            return focusSubject
        }

        let focusSubject = PassthroughSubject<BlockFocusPosition, Never>()
        blocksFocusSubjects[blockId] = focusSubject

        return focusSubject
    }
}
