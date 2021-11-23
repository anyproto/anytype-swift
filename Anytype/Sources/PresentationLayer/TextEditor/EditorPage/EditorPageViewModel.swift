import Foundation
import SwiftUI
import Combine
import os
import BlocksModels
import Amplitude
import AnytypeCore

enum EditorEditingState {
    case editing
    case selecting(blocks: [BlockId])
}

final class EditorPageViewModel: EditorPageViewModelProtocol {
    var editorEditingState: AnyPublisher<EditorEditingState, Never> { $editingState.eraseToAnyPublisher() }

    @Published var editingState: EditorEditingState = .editing

    weak private(set) var viewInput: EditorPageViewInput?
    
    let document: BaseDocumentProtocol
    let modelsHolder: BlockViewModelsHolder
    let blockDelegate: BlockDelegate
    
    let router: EditorRouterProtocol
    
    private let objectHeaderLocalEventsListener = ObjectHeaderLocalEventsListener()
    private let cursorManager = EditorCursorManager()
    let objectSettingsViewModel: ObjectSettingsViewModel
    let actionHandler: BlockActionHandlerProtocol
    let wholeBlockMarkupViewModel: MarkupViewModel
    
    private let blockBuilder: BlockViewModelBuilder
    private let headerBuilder: ObjectHeaderBuilder
    private lazy var cancellables = [AnyCancellable]()

    private let blockActionsService: BlockActionsServiceSingle
    private weak var blocksSelectionOverlayViewModel: BlocksSelectionOverlayViewModel?
    var selectedBlocksIndexPaths = [IndexPath]()

    deinit {
        blockActionsService.close(contextId: document.objectId, blockId: document.objectId)

        EventsBunch(
            objectId: MiddlewareConfigurationService.shared.configuration().homeBlockID,
            localEvents: [.documentClosed(blockId: document.objectId)]
        ).send()
    }

    // MARK: - Initialization
    init(
        document: BaseDocumentProtocol,
        viewInput: EditorPageViewInput,
        blockDelegate: BlockDelegate,
        objectSettinsViewModel: ObjectSettingsViewModel,
        router: EditorRouterProtocol,
        modelsHolder: BlockViewModelsHolder,
        blockBuilder: BlockViewModelBuilder,
        actionHandler: BlockActionHandler,
        wholeBlockMarkupViewModel: MarkupViewModel,
        headerBuilder: ObjectHeaderBuilder,
        blockActionsService: BlockActionsServiceSingle,
        blocksSelectionOverlayViewModel: BlocksSelectionOverlayViewModel
    ) {
        self.objectSettingsViewModel = objectSettinsViewModel
        self.viewInput = viewInput
        self.document = document
        self.router = router
        self.modelsHolder = modelsHolder
        self.blockBuilder = blockBuilder
        self.actionHandler = actionHandler
        self.blockDelegate = blockDelegate
        self.wholeBlockMarkupViewModel = wholeBlockMarkupViewModel
        self.headerBuilder = headerBuilder
        self.blockActionsService = blockActionsService
        self.blocksSelectionOverlayViewModel = blocksSelectionOverlayViewModel

        actionHandler.blockSelectionHandler = self

        blocksSelectionOverlayViewModel.endEditingModeHandler = { [weak self] in self?.editingState = .editing }
        blocksSelectionOverlayViewModel.blocksOptionViewModel?.tapHandler = { [weak self] in self?.handleBlocksOptionItemSelection($0) }

        setupSubscriptions()
    }

    private func setupSubscriptions() {
        objectHeaderLocalEventsListener.beginObservingEvents { [weak self] event in
            self?.handleObjectHeaderLocalEvent(event)
        }

        document.updatePublisher.sink { [weak self] in
            self?.handleUpdate(updateResult: $0)
        }.store(in: &cancellables)
    }
    
    private func handleObjectHeaderLocalEvent(_ event: ObjectHeaderLocalEvent) {
        let details = document.objectDetails
        let header = headerBuilder.objectHeaderForLocalEvent(
            event,
            details: details
        )

        updateHeaderIfNeeded(header: header, details: details)
    }
    
    private func handleUpdate(updateResult: EventsListenerUpdate) {
        switch updateResult {

        case .general:
            performGeneralUpdate()

        case let .details(id):
            guard id == document.objectId else {
                // TODO: - call blocks update with new details to update mentions/links
                performGeneralUpdate()
                return
            }
            
            // TODO: - also we should check if blocks in current object contains mantions/link to current object if YES we must update blocks with updated details
            let details = document.objectDetails
            let header = headerBuilder.objectHeader(details: details)

            objectSettingsViewModel.update(
                objectDetailsStorage: document.detailsStorage,
                objectRestrictions: document.objectRestrictions,
                objectRelationsStorage: document.parsedRelations
            )
            updateHeaderIfNeeded(header: header, details: details)

            let featuredRelationsBlock = modelsHolder.models.first { blockModel in
                if case .featuredRelations = blockModel.content {
                    return true
                }
                return false
            }
            if let featuredRelationsBlockViewModel = featuredRelationsBlock as? FeaturedRelationsBlockViewModel {
                updateViewModelsWithStructs(Set([featuredRelationsBlockViewModel.blockId]))
                viewInput?.update(blocks: modelsHolder.models)
            }

        case let .blocks(updatedIds):
            guard !updatedIds.isEmpty else {
                return
            }
            
            updateViewModelsWithStructs(updatedIds)
            updateMarkupViewModel(updatedIds)
            
            viewInput?.update(blocks: modelsHolder.models)

        case .syncStatus(let status):
            viewInput?.update(syncStatus: status)
        }
    }
    
    private func performGeneralUpdate() {
        handleDeletionState()
        
        let models = document.flattenBlocks
        
        let blocksViewModels = blockBuilder.build(models)
        
        handleGeneralUpdate(with: blocksViewModels)
        
        updateMarkupViewModel(newBlockViewModels: blocksViewModels)

        cursorManager.handleGeneralUpdate(with: modelsHolder.models, type: document.objectDetails?.type)
    }
    
    private func handleDeletionState() {
        guard let details = document.objectDetails else {
            anytypeAssertionFailure("No detais for general update", domain: .editorPage)
            return
        }
        
        viewInput?.showDeletedScreen(details.isDeleted)
        if details.isArchived {
            router.goBack()
        }
    }
    
    private func updateViewModelsWithStructs(_ blockIds: Set<BlockId>) {
        for blockId in blockIds {
            guard let newRecord = document.blocksContainer.model(id: blockId) else {
                AnytypeLogger(category: "Editor page view model").debug("Could not find object with id: \(blockId)")
                return
            }

            let viewModelIndex = modelsHolder.models.firstIndex {
                $0.blockId == blockId
            }

            guard let viewModelIndex = viewModelIndex else {
                return
            }

            let upperBlock = modelsHolder.models[viewModelIndex].upperBlock
            
            guard
                let newModel = blockBuilder.build(newRecord, previousBlock: upperBlock)
            else {
                anytypeAssertionFailure(
                    "Could not build model from record: \(newRecord)",
                    domain: .editorPage
                )
                return
            }

            modelsHolder.models[viewModelIndex] = newModel
        }
    }
    
    private func updateMarkupViewModel(_ updatedBlockIds: Set<BlockId>) {
        guard let blockIdWithMarkupMenu = wholeBlockMarkupViewModel.blockInformation?.id,
              updatedBlockIds.contains(blockIdWithMarkupMenu) else {
            return
        }
        updateMarkupViewModelWith(informationBy: blockIdWithMarkupMenu)
    }
    
    private func updateMarkupViewModel(newBlockViewModels: [BlockViewModelProtocol]) {
        guard let blockIdWithMarkupMenu = wholeBlockMarkupViewModel.blockInformation?.id else {
            return
        }
        let blockIds = Set(newBlockViewModels.map { $0.blockId })
        guard blockIds.contains(blockIdWithMarkupMenu) else {
            wholeBlockMarkupViewModel.removeInformationAndDismiss()
            return
        }
        updateMarkupViewModelWith(informationBy: blockIdWithMarkupMenu)
    }
    
    private func updateMarkupViewModelWith(informationBy blockId: BlockId) {
        guard let currentInformation = document.blocksContainer.model(id: blockId)?.information else {
            wholeBlockMarkupViewModel.removeInformationAndDismiss()
            anytypeAssertionFailure("Could not find object with id: \(blockId)", domain: .editorPage)
            return
        }
        guard case .text = currentInformation.content else {
            wholeBlockMarkupViewModel.removeInformationAndDismiss()
            return
        }
        wholeBlockMarkupViewModel.blockInformation = currentInformation
    }

    private func handleGeneralUpdate(with models: [BlockViewModelProtocol]) {
        modelsHolder.apply(newModels: models)
        
        let details = document.objectDetails
        let header = headerBuilder.objectHeader(details: details)
        updateHeaderIfNeeded(header: header, details: details)
        viewInput?.update(blocks: modelsHolder.models)

        objectSettingsViewModel.update(
            objectDetailsStorage: document.detailsStorage,
            objectRestrictions: document.objectRestrictions,
            objectRelationsStorage: document.parsedRelations
        )
    }

    // iOS 14 bug fix applying header section while editing
    private func updateHeaderIfNeeded(header: ObjectHeader, details: ObjectDetails?) {
        guard modelsHolder.header != header else { return }

        viewInput?.update(header: header, details: details)
        modelsHolder.header = header
    }

    private func updateSelectionContent(selectedBlocks: [BlockInformation]) {
        let restrictions = selectedBlocks.compactMap { BlockRestrictionsBuilder.build(contentType: $0.content.type) }

        blocksSelectionOverlayViewModel?.setSelectedBlocksCount(selectedBlocks.count)
        blocksSelectionOverlayViewModel?.blocksOptionViewModel?.options = restrictions.mergedOptions
    }
}

// MARK: - View output

extension EditorPageViewModel {
    func viewLoaded() {
        guard document.open() else {
            router.goBack()
            return
        }
        
        Amplitude.instance().logDocumentShow(document.objectId)
    }

    func viewAppeared() {
        cursorManager.didAppeared(with: modelsHolder.models, type: document.objectDetails?.type)
    }
}

// MARK: - Selection Handling

extension EditorPageViewModel {
    func didSelectBlock(at index: IndexPath) {
        element(at: index)?.didSelectRowInTableView()
    }

    func didUpdateSelectedIndexPaths(_ indexPaths: [IndexPath]) {
        selectedBlocksIndexPaths = indexPaths
        let elements = indexPaths.compactMap { element(at: $0)?.information }

        updateSelectionContent(selectedBlocks: elements)
    }

    func element(at: IndexPath) -> BlockViewModelProtocol? {
        guard modelsHolder.models.indices.contains(at.row) else {
            anytypeAssertionFailure("Row doesn't exist", domain: .editorPage)
            return nil
        }
        return modelsHolder.models[at.row]
    }
}

extension EditorPageViewModel {
    
    func showSettings() {
        router.showSettings(viewModel: objectSettingsViewModel)
    }
    
    func showIconPicker() {
        router.showIconPicker(viewModel: objectSettingsViewModel.iconPickerViewModel)
    }
    
    func showCoverPicker() {
        router.showCoverPicker(viewModel: objectSettingsViewModel.coverPickerViewModel)
    }
}

extension EditorPageViewModel: BlockSelectionHandler {
    func didSelectEditingState(on block: BlockInformation) {
        editingState = .selecting(blocks: [block.id])
        updateSelectionContent(selectedBlocks: [block])
    }
}

// MARK: - Debug

extension EditorPageViewModel: CustomDebugStringConvertible {
    var debugDescription: String {
        "\(String(reflecting: Self.self)) -> \(String(describing: document.objectId))"
    }
}
