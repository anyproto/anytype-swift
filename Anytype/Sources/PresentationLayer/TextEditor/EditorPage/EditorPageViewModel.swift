import Foundation
import SwiftUI
import Combine
import os
import BlocksModels
import Amplitude
import AnytypeCore

enum EditorEditingState {
    case none
    case editing
    case selected(numberOfRowsSelected: Int)
}

final class EditorPageViewModel: EditorPageViewModelProtocol {
    weak private(set) var viewInput: EditorPageViewInput?
    
    let document: BaseDocumentProtocol
    let modelsHolder: ObjectContentViewModelsSharedHolder
    let blockDelegate: BlockDelegate
    
    let router: EditorRouterProtocol
    
    private let objectHeaderLocalEventsListener = ObjectHeaderLocalEventsListener()
    private let cursorManager = EditorCursorManager()
    let objectSettingsViewModel: ObjectSettingsViewModel
    let blockActionHandler: EditorActionHandlerProtocol
    let wholeBlockMarkupViewModel: MarkupViewModel
    
    private let blockBuilder: BlockViewModelBuilder
    private let headerBuilder: ObjectHeaderBuilder
    private lazy var cancellables = [AnyCancellable]()

    private let blockActionsService: BlockActionsServiceSingle

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
        modelsHolder: ObjectContentViewModelsSharedHolder,
        blockBuilder: BlockViewModelBuilder,
        blockActionHandler: EditorActionHandler,
        wholeBlockMarkupViewModel: MarkupViewModel,
        headerBuilder: ObjectHeaderBuilder,
        blockActionsService: BlockActionsServiceSingle
    ) {
        self.objectSettingsViewModel = objectSettinsViewModel
        self.viewInput = viewInput
        self.document = document
        self.router = router
        self.modelsHolder = modelsHolder
        self.blockBuilder = blockBuilder
        self.blockActionHandler = blockActionHandler
        self.blockDelegate = blockDelegate
        self.wholeBlockMarkupViewModel = wholeBlockMarkupViewModel
        self.headerBuilder = headerBuilder
        self.blockActionsService = blockActionsService
        
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
        
        viewInput?.update(header: header, details: details)
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

            objectSettingsViewModel.update(with: details, objectRestrictions: document.objectRestrictions)
            viewInput?.update(header: header, details: details)
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
            anytypeAssertionFailure("No detais for general update")
            return
        }
        
        viewInput?.showDeletedScreen(details.isDeleted)
        if details.isArchived {
            if FeatureFlags.aletOnGoBack {
                showAssertionAlert("Man this is an archived page\n\(details)")
            }
            router.goBack()
        }
    }
    
    private func updateViewModelsWithStructs(_ blockIds: Set<BlockId>) {
        for blockId in blockIds {
            guard let newRecord = document.blocksContainer
                    .model(id: document.objectId)?
                    .container?.model(id: blockId)
            else {
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
                anytypeAssertionFailure("Could not build model from record: \(newRecord)")
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
        let container = document.blocksContainer.model(id: document.objectId)?.container
        guard let currentInformation = container?.model(id: blockId)?.information else {
            wholeBlockMarkupViewModel.removeInformationAndDismiss()
            anytypeAssertionFailure("Could not find object with id: \(blockId)")
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
        viewInput?.update(header: header, details: details)
        viewInput?.update(blocks: modelsHolder.models)
        
        objectSettingsViewModel.update(with: details, objectRestrictions: document.objectRestrictions)
    }
}

// MARK: - View output

extension EditorPageViewModel {
    func viewLoaded() {
        guard document.open() else {
            if FeatureFlags.aletOnGoBack {
                showAssertionAlert("Could not open page 😫")
            }
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

    private func element(at: IndexPath) -> BlockViewModelProtocol? {
        guard modelsHolder.models.indices.contains(at.row) else {
            anytypeAssertionFailure("Row doesn't exist")
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

// MARK: - Debug

extension EditorPageViewModel: CustomDebugStringConvertible {
    var debugDescription: String {
        "\(String(reflecting: Self.self)) -> \(String(describing: document.objectId))"
    }
}
