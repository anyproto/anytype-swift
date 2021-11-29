import BlocksModels
import Combine
import AnytypeCore

enum EditorEditingState {
    case editing
    case selecting(blocks: [BlockId])
    case moving(indexPaths: [IndexPath])
}

/// Blocks drag & drop protocol.
protocol EditorPageMovingManagerProtocol {
    var movingBlocksIndexPaths: [IndexPath] { get }
    var dividerPositionIndexPath: IndexPath? { get }

    func canPlaceDividerAtIndexPath(_ indexPath: IndexPath) -> Bool
    func didSelectMovingIndexPaths(_ indexPaths: [IndexPath])
}

protocol EditorPageSelectionManagerProtocol {
    var selectedBlocksIndexPaths: [IndexPath] { get }

    func canSelectBlock(at indexPath: IndexPath) -> Bool
    func didLongTap(at indexPath: IndexPath)
    func didUpdateSelectedIndexPaths(_ indexPaths: [IndexPath])
}

protocol EditorPageBlocksStateManagerProtocol: EditorPageSelectionManagerProtocol, EditorPageMovingManagerProtocol {
    var editorEditingState: AnyPublisher<EditorEditingState, Never> { get }
}

final class EditorPageBlocksStateManager: EditorPageBlocksStateManagerProtocol {
    var editorEditingState: AnyPublisher<EditorEditingState, Never> { $editingState.eraseToAnyPublisher()
    }
    @Published var editingState: EditorEditingState = .editing

    private(set) var selectedBlocksIndexPaths = [IndexPath]()
    private(set) var movingBlocksIndexPaths = [IndexPath]()
    private(set) var dividerPositionIndexPath: IndexPath?

    private let document: BaseDocumentProtocol
    private let modelsHolder: BlockViewModelsHolder
    private let blockActionsService: BlockActionsServiceSingle
    private let actionHandler: BlockActionHandlerProtocol

    weak var blocksSelectionOverlayViewModel: BlocksSelectionOverlayViewModel?

    private var cancellables = [AnyCancellable]()

    init(
        document: BaseDocumentProtocol,
        modelsHolder: BlockViewModelsHolder,
        blocksSelectionOverlayViewModel: BlocksSelectionOverlayViewModel,
        blockActionsService: BlockActionsServiceSingle,
        actionHandler: BlockActionHandlerProtocol
    ) {
        self.document = document
        self.modelsHolder = modelsHolder
        self.blocksSelectionOverlayViewModel = blocksSelectionOverlayViewModel
        self.blockActionsService = blockActionsService
        self.actionHandler = actionHandler

        setupEditingHandlers()
    }

    // MARK: - EditorPageSelectionManagerProtocol

    func canSelectBlock(at indexPath: IndexPath) -> Bool {
        guard let block = element(at: indexPath) else { return false }

        if block.content.type == .text(.title) ||
            block.content.type == .featuredRelations {
            return false
        }

        return true
    }

    func didLongTap(at indexPath: IndexPath) {
        guard canSelectBlock(at: indexPath) else { return }

        element(at: indexPath).map {
            didSelectEditingState(on: $0.information)
        }
    }

    func didUpdateSelectedIndexPaths(_ indexPaths: [IndexPath]) {
        selectedBlocksIndexPaths = indexPaths

        blocksSelectionOverlayViewModel?.setSelectedBlocksCount(indexPaths.count)
    }

    // MARK: - EditorPageMovingManagerProtocol

    func didSelectMovingIndexPaths(_ indexPaths: [IndexPath]) {
        movingBlocksIndexPaths = indexPaths
    }

    func canPlaceDividerAtIndexPath(_ indexPath: IndexPath) -> Bool {
        guard indexPath.section == 1 else { return false }

        let notAllowedTypes: [BlockContentType] = [.text(.title), .featuredRelations]

        if let element = modelsHolder.models[safe: indexPath.row],
           !notAllowedTypes.contains(element.content.type) {
            dividerPositionIndexPath = indexPath
            return true
        }

        // Divider can be placed at the bottom of last cell.
        if indexPath.row == modelsHolder.models.count {
            dividerPositionIndexPath = indexPath
            return true
        }

        return false
    }

    // MARK: - Private

    private func setupEditingHandlers() {
        $editingState.sink { [unowned self] state in
            switch state {
            case .selecting(let blocks):
                movingBlocksIndexPaths.removeAll()
                blocksSelectionOverlayViewModel?.setSelectedBlocksCount(blocks.count)
            case .moving:
                blocksSelectionOverlayViewModel?.setNeedsUpdateForMovingState()
            case .editing:
                movingBlocksIndexPaths.removeAll()
            }
        }.store(in: &cancellables)

        blocksSelectionOverlayViewModel?.endEditingModeHandler = { [weak self] in self?.editingState = .editing }
        blocksSelectionOverlayViewModel?.blocksOptionViewModel?.tapHandler = { [weak self] in self?.handleBlocksOptionItemSelection($0) }
        blocksSelectionOverlayViewModel?.moveButtonHandler = { [weak self] in
            self?.startMoving()
        }
        blocksSelectionOverlayViewModel?.cancelButtonHandler = { [weak self] in
            self?.editingState = .editing
        }
    }

    private func updateSelectionContent(selectedBlocks: [BlockInformation]) {
        let restrictions = selectedBlocks.compactMap { BlockRestrictionsBuilder.build(contentType: $0.content.type) }

        blocksSelectionOverlayViewModel?.blocksOptionViewModel?.options = restrictions.mergedOptions
    }

    private func startMoving() {
        guard let positionIndexPath = dividerPositionIndexPath else {
            anytypeAssertionFailure("Unxpected case", domain: .editorPage)
            return
        }

        let position: BlockPosition
        let dropTargetId: BlockId

        if let targetBlock = modelsHolder.models[safe: positionIndexPath.row] {
            position = .top
            dropTargetId = targetBlock.blockId
        } else if let targetBlock = modelsHolder.models[safe: positionIndexPath.row - 1] {
            position = .bottom
            dropTargetId = targetBlock.blockId
        } else {
            anytypeAssertionFailure("Unxpected case", domain: .editorPage)
            return
        }

        let blockIds = movingBlocksIndexPaths
            .sorted()
            .compactMap { element(at: $0)?.blockId }

        blockActionsService.move(
            contextId: document.objectId,
            blockIds: blockIds,
            targetContextID: document.objectId,
            dropTargetID: dropTargetId,
            position: position
        )

        editingState = .editing
    }

    private func didTapEndSelectionModeButton() {
        editingState = .editing
    }

    private func handleBlocksOptionItemSelection(_ item: BlocksOptionItem) {
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
            didSelectMovingIndexPaths(selectedBlocksIndexPaths)
            editingState = .moving(indexPaths: selectedBlocksIndexPaths)

            return
        }

        editingState = .editing
    }

    private func element(at: IndexPath) -> BlockViewModelProtocol? {
        modelsHolder.models[safe: at.row]
    }
}

extension EditorPageBlocksStateManager: BlockSelectionHandler {
    func didSelectEditingState(on block: BlockInformation) {
        editingState = .selecting(blocks: [block.id])
        updateSelectionContent(selectedBlocks: [block])
    }
}
