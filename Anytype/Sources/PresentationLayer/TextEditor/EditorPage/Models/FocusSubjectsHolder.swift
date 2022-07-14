import BlocksModels
import Combine

final class FocusSubjectsHolder {
    var blocksFocusSubjects = Dictionary<BlockId, PassthroughSubject<BlockFocusPosition, Never>>()

    func focusSubject(for blockId: BlockId) -> PassthroughSubject<BlockFocusPosition, Never> {
        if let focusSubject = blocksFocusSubjects[blockId] {
            return focusSubject
        }

        let focusSubject = PassthroughSubject<BlockFocusPosition, Never>()
        blocksFocusSubjects[blockId] = focusSubject

        return focusSubject
    }
}
