import Services
import Combine

final class FocusSubjectsHolder {
    var blocksFocusSubjects = Dictionary<String, PassthroughSubject<BlockFocusPosition, Never>>()

    func focusSubject(for blockId: String) -> PassthroughSubject<BlockFocusPosition, Never> {
        if let focusSubject = blocksFocusSubjects[blockId] {
            return focusSubject
        }

        let focusSubject = PassthroughSubject<BlockFocusPosition, Never>()
        blocksFocusSubjects[blockId] = focusSubject

        return focusSubject
    }
}
