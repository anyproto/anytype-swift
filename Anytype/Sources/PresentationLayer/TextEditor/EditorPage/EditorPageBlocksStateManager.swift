import Services
import Combine
import AnytypeCore
import Foundation
import UIKit

enum EditorEditingState {
    case editing
    case selecting(blocks: [String])
    case moving(indexPaths: [IndexPath])
    case readonly
    case simpleTablesSelection(block: String, selectedBlocks: [String], simpleTableMenuModel: SimpleTableMenuModel)
    case loading
}

/// Blocks drag & drop protocol.
@MainActor
protocol EditorPageMovingManagerProtocol {
    func canPlaceDividerAtIndexPath(_ indexPath: IndexPath) -> Bool
    func canMoveItemsToObject(at indexPath: IndexPath) -> Bool

    func moveItem(with blockDragConfiguration: BlockDragConfiguration)

    func didSelectMovingIndexPaths(_ indexPaths: [IndexPath])
    func didSelectEditingMode()
}

@MainActor
protocol EditorPageSelectionManagerProtocol {
    func canSelectBlock(at indexPath: IndexPath) -> Bool
    func didLongTap(at indexPath: IndexPath)
    func didUpdateSelectedIndexPaths(_ indexPaths: [IndexPath])

    // MARK: - Optional
    func didSelectSelection(from indexPath: IndexPath)}

extension EditorPageSelectionManagerProtocol {
    func didSelectSelection(from indexPath: IndexPath) {}
}

@MainActor
protocol EditorPageBlocksStateManagerProtocol: EditorPageSelectionManagerProtocol, EditorPageMovingManagerProtocol, AnyObject {
    func checkOpenedState()
    
    var editingState: EditorEditingState { get }
    var editorEditingStatePublisher: AnyPublisher<EditorEditingState, Never> { get }
    var editorSelectedBlocks: AnyPublisher<[String], Never> { get }
}

@MainActor
final class EditorPageBlocksStateManager: EditorPageBlocksStateManagerProtocol {
    private enum MovingDestination {
        case position(IndexPath)
        case object(String)
    }

    var editorEditingStatePublisher: AnyPublisher<EditorEditingState, Never> { $editingState.eraseToAnyPublisher() }
    var editorSelectedBlocks: AnyPublisher<[String], Never> { $selectedBlocks.eraseToAnyPublisher() }

    @Published var editingState: EditorEditingState = .editing
    @Published var selectedBlocks = [String]()

    private(set) var selectedBlocksIndexPaths = [IndexPath]()
    private(set) var movingBlocksIds = [String]()
    private var movingDestination: MovingDestination?

    // We need to store interspace between root and all childs to disable cursor moving between those indexPaths
    private var movingBlocksWithChildsIndexPaths = [[IndexPath]]()

    private let document: BaseDocumentProtocol
    private let modelsHolder: EditorMainItemModelsHolder
    private let blockService: BlockServiceProtocol
    private let toastPresenter: ToastPresenterProtocol
    private let actionHandler: BlockActionHandlerProtocol
    private let pasteboardService: PasteboardBlockDocumentServiceProtocol
    private let router: EditorRouterProtocol
    private let bottomNavigationManager: EditorBottomNavigationManagerProtocol
    private let documentsProvider: DocumentsProviderProtocol
    
    weak var blocksOptionViewModel: SelectionOptionsViewModel?
    weak var blocksSelectionOverlayViewModel: BlocksSelectionOverlayViewModel?
    weak var viewInput: EditorPageViewInput?

    private var cancellables = [AnyCancellable]()

    init(
        document: BaseDocumentProtocol,
        modelsHolder: EditorMainItemModelsHolder,
        blocksSelectionOverlayViewModel: BlocksSelectionOverlayViewModel,
        blockService: BlockServiceProtocol,
        toastPresenter: ToastPresenterProtocol,
        actionHandler: BlockActionHandlerProtocol,
        pasteboardService: PasteboardBlockDocumentServiceProtocol,
        router: EditorRouterProtocol,
        initialEditingState: EditorEditingState,
        viewInput: EditorPageViewInput,
        bottomNavigationManager: EditorBottomNavigationManagerProtocol,
        documentsProvider: DocumentsProviderProtocol
    ) {
        self.document = document
        self.modelsHolder = modelsHolder
        self.blocksSelectionOverlayViewModel = blocksSelectionOverlayViewModel
        self.blockService = blockService
        self.toastPresenter = toastPresenter
        self.actionHandler = actionHandler
        self.pasteboardService = pasteboardService
        self.router = router
        self.editingState = initialEditingState
        self.viewInput = viewInput
        self.bottomNavigationManager = bottomNavigationManager
        self.documentsProvider = documentsProvider

        setupEditingHandlers()
    }

    func checkOpenedState() {
        if !document.isOpened {
            editingState = .loading
        } else if !document.permissions.canEditBlocks {
            editingState = .readonly
        } else if case .editing = editingState {
            // nothing
        } else {
            editingState = .editing
        }
    }
    
    // MARK: - EditorPageSelectionManagerProtocol

    func canSelectBlock(at indexPath: IndexPath) -> Bool {
        guard let block = modelsHolder.blockViewModel(at: indexPath.row) else { return false }

        if block.content.type == .text(.title) || block.content.type == .text(.description) ||
            block.content.type == .featuredRelations {
            return false
        }

        return true
    }

    func didLongTap(at indexPath: IndexPath) {
        guard canSelectBlock(at: indexPath) else { return }

        modelsHolder.blockViewModel(at: indexPath.row).map {
            didSelectEditingState(info: $0.info)
        }
    }

    func didUpdateSelectedIndexPaths(_ indexPaths: [IndexPath]) {
        guard indexPaths.count > 0 else {
            resetToEditingMode()
            return
        }

        selectedBlocksIndexPaths = indexPaths

        blocksSelectionOverlayViewModel?.state = .editorMenu(selectedBlocksCount: indexPaths.count)

        let blocksInformation = indexPaths.compactMap {
            modelsHolder.blockViewModel(at: $0.row)?.info
        }
        updateSelectionBarActions(selectedBlocks: blocksInformation)

        if case .selecting = editingState {
            editingState = .selecting(blocks: blocksInformation.map { $0.id })
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }

    // MARK: - EditorPageMovingManagerProtocol
    func moveItem(with blockDragConfiguration: BlockDragConfiguration) {
        movingBlocksIds = [blockDragConfiguration.id]
        startMoving()
    }

    func didSelectMovingIndexPaths(_ indexPaths: [IndexPath]) {
        movingBlocksIds = indexPaths
            .sorted()
            .compactMap { modelsHolder.blockViewModel(at: $0.row)?.blockId }
    }

    func canPlaceDividerAtIndexPath(_ indexPath: IndexPath) -> Bool {
        guard indexPath.section == 1 else { return false }

        for indexPathRanges in movingBlocksWithChildsIndexPaths {
            var ranges = indexPathRanges.sorted()

            ranges.removeFirst()
            if ranges.contains(indexPath) { return false }
        }

        let notAllowedTypes: [BlockContentType] = [.text(.title), .featuredRelations]

        if let element = modelsHolder.blockViewModel(at: indexPath.row),
           !notAllowedTypes.contains(element.content.type) {
            movingDestination = .position(indexPath)
            return true
        }

        // Divider can be placed at the bottom of last cell.
        if indexPath.row == modelsHolder.items.count {
            movingDestination = .position(indexPath)
            return true
        }

        return false
    }

    func didSelectEditingMode() {
        if case let .simpleTablesSelection(_, _, simpleTableMenuModel) = editingState {
            simpleTableMenuModel.onDone()
        }

        editingState = .editing
    }

    func canMoveItemsToObject(at indexPath: IndexPath) -> Bool {
        guard !movingBlocksWithChildsIndexPaths.flatMap({ $0 }).contains(indexPath),
              let element = modelsHolder.blockViewModel(at: indexPath.row) else { return false }

        switch element.content.type {
        case .file, .divider, .relation,
                .dataView, .featuredRelations,
                .bookmark, .smartblock, .text(.title), .table:
            return false
        default:
            movingDestination = .object(element.blockId)

            return true
        }
    }

    // MARK: - Private

    private func setupEditingHandlers() {
        $editingState.sink { [weak self] state in
            guard let self else { return }
            switch state {
            case .selecting(let blocks):
                blocksSelectionOverlayViewModel?.state = .editorMenu(selectedBlocksCount: blocks.count)
            case .moving:
                blocksSelectionOverlayViewModel?.state = .moving
            case .editing:
                movingBlocksIds.removeAll()
            case .readonly, .loading:
                break
            case let .simpleTablesSelection(_,  blocks, model):
                blocksSelectionOverlayViewModel?.state = .simpleTableMenu(selectedBlocksCount: blocks.count, model: model)
            }
        }.store(in: &cancellables)


        blocksSelectionOverlayViewModel?.moveButtonHandler = { [weak self] in
            self?.startMoving()
        }
        blocksSelectionOverlayViewModel?.cancelButtonHandler = { [weak self] in
            self?.editingState = .editing
        }
    }

    private func updateSelectionBarActions(selectedBlocks: [BlockInformation]) {
        let availableItems = selectedBlocks.blocksOptionItems(document: document)
        let horizontalItems = availableItems.map { item in
            SelectionOptionsItemViewModel(
                id: "\(item.hashValue)",
                title: item.title,
                imageAsset: item.imageAsset
            ) { [weak self] in
                self?.handleBlocksOptionItemSelection(item)
            }
        }

        blocksOptionViewModel?.items = horizontalItems
    }

    func startMoving() {
        switch movingDestination {
        case let .object(blockId):
            if let info = document.infoContainer.get(id: blockId),
               case let .link(content) = info.content {
                let targetDocument = documentsProvider.document(objectId: content.targetBlockID, forPreview: false)
            
                Task { @MainActor [weak self] in
                    try? await targetDocument.open()
                    guard let id = targetDocument.children.last?.id,
                          let details = targetDocument.details else { return }
                    self?.move(position: .bottom, targetId: targetDocument.objectId, dropTargetId: id)
                    
                    self?.toastPresenter.showObjectCompositeAlert(
                        prefixText: Loc.Editor.Toast.movedTo,
                        objectId: targetDocument.objectId,
                        tapHandler: { [weak self] in
                            self?.router.showEditorScreen(data: details.editorScreenData())
                        }
                    )
                }
            } else {
                move(position: .inner, targetId: document.objectId, dropTargetId: blockId)
            }
        case let .position(positionIndexPath):
            let position: BlockPosition
            let dropTargetId: String
            if let targetBlock = modelsHolder.blockViewModel(at: positionIndexPath.row) {
                position = .top
                dropTargetId = targetBlock.blockId
            } else if let targetBlock = modelsHolder.blockViewModel(at: positionIndexPath.row - 1) {
                position = .bottom
                dropTargetId = targetBlock.blockId
            } else {
                anytypeAssertionFailure("Unxpected case")
                return
            }
            move(position: position, targetId: document.objectId, dropTargetId: dropTargetId)
        case .none:
            anytypeAssertionFailure("Unxpected case")
            return
        }
    }
    
    private func move(position: BlockPosition, targetId: String, dropTargetId: String) {
        guard !movingBlocksIds.contains(dropTargetId) else { return }

        UISelectionFeedbackGenerator().selectionChanged()
        AnytypeAnalytics.instance().logReorderBlock(count: movingBlocksIds.count)
        
        Task { @MainActor in
            try await blockService.move(
                contextId: document.objectId,
                blockIds: movingBlocksIds,
                targetContextID: targetId,
                dropTargetID: dropTargetId,
                position: position
            )
            
            movingBlocksIds.removeAll()
            editingState = .editing
        }
    }

    private func didTapEndSelectionModeButton() {
        editingState = .editing
    }

    private func handleBlocksOptionItemSelection(_ item: BlocksOptionItem) {
        let sortedElements: [IndexPath] = selectedBlocksIndexPaths.sorted()
        let elements = sortedElements.compactMap {
            modelsHolder.blockViewModel(at: $0.row)
        }
        AnytypeAnalytics.instance().logEvent(
            AnalyticsEventsName.blockAction,
            withEventProperties: ["type": item.analyticsEventValue]
        )

        switch item {
        case .delete:
            actionHandler.delete(blockIds: elements.map { $0.blockId } )
        case .addBlockBelow:
            elements.forEach { actionHandler.addBlock(.text(.text), blockId: $0.blockId) }
        case .duplicate:
            elements.forEach { actionHandler.duplicate(blockId: $0.blockId) }
        case .turnInto:
            Task {
                for block in elements {
                    try await actionHandler.turnIntoPage(blockId: block.blockId)
                }
            }
        case .moveTo:
            router.showMoveTo { [weak self] details in
                elements.forEach {
                    self?.actionHandler.moveToPage(blockId: $0.blockId, pageId: details.id)
                }
                self?.editingState = .editing
                
                self?.toastPresenter.showObjectCompositeAlert(
                    prefixText: Loc.Editor.Toast.movedTo,
                    objectId: details.id,
                    tapHandler: { [weak self] in
                        self?.router.showEditorScreen(data: details.editorScreenData())
                    }
                )
            }
            return
        case .move:
            var onlyRootIndexPaths = selectedBlocksIndexPaths
            let allMovingBlocks = selectedBlocksIndexPaths.map { indexPath -> [IndexPath] in
                guard let model = modelsHolder.blockViewModel(at: indexPath.row) else { return [] }

                var childIndexPaths = modelsHolder.allChildIndexes(viewModel: model)
                    .map { IndexPath(row: $0, section: indexPath.section) }

                onlyRootIndexPaths = onlyRootIndexPaths.filter { !childIndexPaths.contains($0) }

                childIndexPaths.append(indexPath)
                return childIndexPaths
            }

            movingBlocksWithChildsIndexPaths = allMovingBlocks
            didSelectMovingIndexPaths(selectedBlocksIndexPaths)
            editingState = .moving(indexPaths: allMovingBlocks.flatMap { $0 })
            movingBlocksIds = onlyRootIndexPaths
                .sorted()
                .compactMap { modelsHolder.blockViewModel(at: $0.row)?.blockId }
            return
        case .download:
            anytypeAssert(
                elements.count == 1,
                "Number of elements should be 1"
            )

            if case let .file(blockFile) = elements.first?.content,
               let url = blockFile.contentUrl {
                router.saveFile(fileURL: url, type: blockFile.contentType)
            }
        case .openObject:
            anytypeAssert(
                elements.count == 1,
                "Number of elements should be 1"
            )
            guard case let .bookmark(bookmark) = elements.first?.content else { return }
            AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.openAsObject)
            router.showPage(objectId: bookmark.targetObjectID)
        case .openSource:
            anytypeAssert(
                elements.count == 1,
                "Number of elements should be 1"
            )
            guard case let .dataView(data) = elements.first?.content else { return }
            AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.openAsSource)
            router.showPage(objectId: data.targetObjectID)
        case .style:
            let elements = elements.map { $0.info }
            editingState = .selecting(blocks: elements.map { $0.id} )
            didSelectStyleSelection(infos: elements)

            return
        case .paste:
            let blockIds = elements.map(\.blockId)

            pasteboardService.pasteInSelectedBlocks(objectId: document.objectId, selectedBlockIds: blockIds) { [weak self] in
                self?.router.showWaitingView(text: Loc.pasteProcessing)
            } completion: { [weak self] _ in
                self?.router.hideWaitingView()
            }

        case .copy:
            var blocksIds = elements.map(\.blockId)

            let blockInformations = blocksIds.compactMap(document.infoContainer.get(id:))

            blockInformations.forEach { blockInformation in
                if blockInformation.content == .table {
                    let recursiveChilds = document.infoContainer.recursiveChildren(of: blockInformation.id).map { $0.id }
                    blocksIds.append(contentsOf: recursiveChilds)
                }
            }

            AnytypeAnalytics.instance().logCopyBlock()
            Task { @MainActor [blocksIds] in
                try await pasteboardService.copy(document: document, blocksIds: blocksIds, selectedTextRange: NSRange())
                toastPresenter.show(message: Loc.copied)
            }
        case .preview:
            elements.first.map {
                let blockId = $0.blockId

                guard case let .link(blockLink) = $0.info.content,
                      let details = document.detailsStorage.get(id: blockLink.targetBlockID) else { return }

                let blockLinkState = BlockLinkState(details: details, blockLink: blockLink)
                
                router.showObjectPreview(blockLinkState: blockLinkState) { [weak self] appearance in
                    self?.actionHandler.setAppearance(blockId: blockId, appearance: appearance)
                }
            }
        }

        editingState = .editing
    }

    private func resetToEditingMode() {
        movingDestination = nil
        selectedBlocksIndexPaths.removeAll()
        movingBlocksIds.removeAll()
        movingBlocksWithChildsIndexPaths.removeAll()

        editingState = .editing
    }
}

extension EditorPageBlocksStateManager: SimpleTableSelectionHandler {
    func didStartSimpleTableSelectionMode(simpleTableBlockId: String, selectedBlockIds: [String], menuModel: SimpleTableMenuModel) {
        editingState = .simpleTablesSelection(
            block: simpleTableBlockId,
            selectedBlocks: selectedBlockIds,
            simpleTableMenuModel: menuModel
        )
    }

    func didStopSimpleTableSelectionMode() {
        editingState = .editing
    }
}

extension EditorPageBlocksStateManager {
    func didSelectSelection(from indexPath: IndexPath) {
        guard let blockViewModel = modelsHolder.blockViewModel(at: indexPath.row) else { return }

        editingState = .selecting(blocks: [blockViewModel.info.id])
        selectedBlocks = [blockViewModel.info.id]
        updateSelectionBarActions(selectedBlocks: [blockViewModel.info])
    }

    func didSelectEditingState(info: BlockInformation) {
        editingState = .selecting(blocks: [info.id])
        selectedBlocks = [info.id]
        updateSelectionBarActions(selectedBlocks: [info])
    }

    func didSelectStyleSelection(infos: [BlockInformation]) {
        viewInput?.endEditing()
        bottomNavigationManager.styleViewActive(true)
        selectedBlocks = infos.map { $0.id }

        let restrictions = BlockRestrictionsBuilder.build(contents: infos.map { $0.content })
        router.showStyleMenu(informations: infos, restrictions: restrictions) { [weak self] presentedView in
            self?.viewInput?.adjustContentOffset(relatively: presentedView)
        } onDismiss: { [weak self] in
            self?.editingState = .editing
            self?.bottomNavigationManager.styleViewActive(false)
            self?.viewInput?.restoreEditingState()
        }
    }
}

extension EditorMainItemModelsHolder {
    func allChildIndexes(viewModel: BlockViewModelProtocol) -> [Int] {
        allIndexes(for: viewModel.info.childrenIds.map { $0 })
    }

    private func allIndexes(for childs: [String]) -> [Int] {
        var indexes = [Int]()

        for child in childs {
            guard let index = items.firstIndex(blockId: child) else {
                continue
            }

            indexes.append(index)

            guard let modelChilds = blockViewModel(at: index)?.info.childrenIds else { continue }
            indexes.append(contentsOf: allIndexes(for: modelChilds.map { $0 }))
        }

        return indexes
    }
}
