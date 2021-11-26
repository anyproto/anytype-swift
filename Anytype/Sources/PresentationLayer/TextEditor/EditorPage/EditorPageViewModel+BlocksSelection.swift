import Combine

extension EditorPageViewModel {
    func setupEditingHandlers() {
        $editingState.sink { [unowned self] state in
            blocksSelectionOverlayViewModel?.editorEditingStateDidChanged(state)
        }.store(in: &cancellables)

        actionHandler.blockSelectionHandler = self

        blocksSelectionOverlayViewModel?.endEditingModeHandler = { [weak self] in self?.editingState = .editing }
        blocksSelectionOverlayViewModel?.blocksOptionViewModel?.tapHandler = { [weak self] in self?.handleBlocksOptionItemSelection($0) }
        blocksSelectionOverlayViewModel?.moveButtonHandler = { [weak self] in
            self?.startMoving()
        }
    }
}

extension EditorPageViewModel {
    func startMoving() {
        guard let positionIndexPath = blocksSelectionManager.dividerPositionIndexPath,
              let element = element(at: positionIndexPath) else { return }

        let blockIds = blocksSelectionManager
            .movingBlocksIndexPaths
            .compactMap { element(at: $0).blockId }

        blockActionsService.move(
            contextId: document.objectId,
            blockIds: blockIds,
            targetContextID: document.objectId,
            dropTargetID: element.blockId
        )

        editingState = .editing
    }

    func didTapEndSelectionModeButton() {
        editingState = .editing
    }

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
            elements.forEach { actionHandler.turnIntoPage(blockId: $0.blockId) }
        case .moveTo:
            movingBlocksIndexPaths = selectedBlocksIndexPaths
            editingState = .moving(indexPaths: selectedBlocksIndexPaths)

            return
        }

        editingState = .editing
    }
}
