import Combine

extension EditorPageViewModel {
    func didTapEndSelectionModeButton() {
        editingState = .editing
    }
}

extension EditorPageViewModel {
    func handleBlocksOptionItemSelection(_ item: BlocksOptionItem) {
        let elements = selectedBlocksIndexPaths.compactMap(element(at:))

        switch item {
        case .delete:
            elements.forEach { actionHandler.delete(blockId: $0.blockId) }
        case .addBlockBelow:
            elements.forEach { actionHandler.addBlock(.text(.text), blockId: $0.blockId) }
        case .duplicate:
            elements.forEach { actionHandler.duplicate(blockId: $0.blockId) }
        case .turnInto:
            break
        case .moveTo:
            break
        }

        editingState = .editing
    }
}
