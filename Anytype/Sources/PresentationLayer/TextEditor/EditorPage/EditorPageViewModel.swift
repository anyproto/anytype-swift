import Foundation
import SwiftUI
import Combine
import os
import BlocksModels
import Amplitude
import AnytypeCore

final class EditorPageViewModel: EditorPageViewModelProtocol {
    weak private(set) var viewInput: EditorPageViewInput?

    let blocksStateManager: EditorPageBlocksStateManagerProtocol

    let document: BaseDocumentProtocol
    let modelsHolder: BlockViewModelsHolder
    let blockDelegate: BlockDelegate
    
    let router: EditorRouterProtocol
    
    private let objectHeaderLocalEventsListener = ObjectHeaderLocalEventsListener()
    private let cursorManager: EditorCursorManager
    let objectSettingsViewModel: ObjectSettingsViewModel
    let actionHandler: BlockActionHandlerProtocol
    let wholeBlockMarkupViewModel: MarkupViewModel
    
    private let blockBuilder: BlockViewModelBuilder
    private let headerBuilder: ObjectHeaderBuilder
    private lazy var cancellables = [AnyCancellable]()

    private let blockActionsService: BlockActionsServiceSingle

    deinit {
        blockActionsService.close(contextId: document.objectId, blockId: document.objectId)

        EventsBunch(
            contextId: MiddlewareConfigurationService.shared.configuration().homeBlockID,
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
        blocksStateManager: EditorPageBlocksStateManagerProtocol,
        cursorManager: EditorCursorManager
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
        self.blocksStateManager = blocksStateManager
        self.cursorManager = cursorManager

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
                #warning("call blocks update with new details to update mentions/links")
                performGeneralUpdate()
                return
            }
            
            #warning("also we should check if blocks in current object contains mantions/link to current object if YES we must update blocks with updated details")
            let details = document.objectDetails
            let header = headerBuilder.objectHeader(details: details)

            objectSettingsViewModel.update(
                objectRestrictions: document.objectRestrictions,
                parsedRelations: document.parsedRelations
            )
            updateHeaderIfNeeded(header: header, details: details)

            let featuredRelationsBlock = modelsHolder.models.first { blockModel in
                if case .featuredRelations = blockModel.content {
                    return true
                }
                return false
            }
            if let featuredRelationsBlockViewModel = featuredRelationsBlock as? FeaturedRelationsBlockViewModel {
                let diffrerence = difference(with: Set([featuredRelationsBlockViewModel.blockId]))
                modelsHolder.applyDifference(difference: diffrerence)
                viewInput?.update(changes: diffrerence, allModels: modelsHolder.models)
            }

        case let .blocks(updatedIds):
            guard !updatedIds.isEmpty else {
                return
            }
            
            let diffrerence = difference(with: updatedIds)
            updateMarkupViewModel(updatedIds)

            modelsHolder.applyDifference(difference: diffrerence)
            viewInput?.update(changes: diffrerence, allModels: modelsHolder.models)

            updateCursorIfNeeded()
        case .syncStatus(let status):
            viewInput?.update(syncStatus: status)
        case .dataSourceUpdate:
            let models = document.flattenBlocks

            let blocksViewModels = blockBuilder.build(models)
            modelsHolder.models = blocksViewModels

            viewInput?.update(changes: nil, allModels: blocksViewModels)
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


    private func difference(
        with blockIds: Set<BlockId>
    ) -> CollectionDifference<BlockViewModelProtocol> {
        var currentModels = modelsHolder.models
        
        for (offset, model) in modelsHolder.models.enumerated() {
            for blockId in blockIds {
                if model.blockId == blockId {
                    guard let model = document.blocksContainer.model(id: blockId),
                          let newViewModel = blockBuilder.build(model, previousBlock: nil) else {
                              continue
                          }


                    currentModels[offset] = newViewModel
                }
            }
        }

        return modelsHolder.difference(between: currentModels)
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
            AnytypeLogger(category: "Editor page view model").debug("Could not find object with id: \(blockId)")
            return
        }
        guard case .text = currentInformation.content else {
            wholeBlockMarkupViewModel.removeInformationAndDismiss()
            return
        }
        wholeBlockMarkupViewModel.blockInformation = currentInformation
    }

    private func handleGeneralUpdate(with models: [BlockViewModelProtocol]) {
        let difference = modelsHolder.difference(between: models)
        if !difference.isEmpty {
            modelsHolder.applyDifference(difference: difference)
        } else {
            modelsHolder.models = models
        }

        
        let details = document.objectDetails
        let header = headerBuilder.objectHeader(details: details)
        updateHeaderIfNeeded(header: header, details: details)
        viewInput?.update(changes: difference, allModels: modelsHolder.models)

        objectSettingsViewModel.update(
            objectRestrictions: document.objectRestrictions,
            parsedRelations: document.parsedRelations
        )

        updateCursorIfNeeded()
    }

    private func updateCursorIfNeeded() {
        if let blockFocus = cursorManager.blockFocus,
           let block = modelsHolder.contentProvider(for: blockFocus.id) {

            block.set(focus: blockFocus.position)
            cursorManager.blockFocus = nil
        }
    }

    // iOS 14 bug fix applying header section while editing
    private func updateHeaderIfNeeded(header: ObjectHeader, details: ObjectDetails?) {
        guard modelsHolder.header != header else { return }

        viewInput?.update(header: header, details: details)
        modelsHolder.header = header
    }
}

// MARK: - View output

extension EditorPageViewModel {
    func viewDidLoad() {
        if let objectDetails = document.objectDetails {
            Amplitude.instance().logShowObject(type: objectDetails.type, layout: objectDetails.layout)
        }
    }
    
    func viewWillAppear() {
        guard document.open() else {
            router.goBack()
            return
        }
    }

    func viewDidAppear() {
        cursorManager.didAppeared(with: modelsHolder.models, type: document.objectDetails?.type)
    }
    
    func viewWillDisappear() {
        document.close()
    }
}

// MARK: - Selection Handling

extension EditorPageViewModel {
    func didSelectBlock(at indexPath: IndexPath) {
        element(at: indexPath)?.didSelectRowInTableView()
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

// MARK: - Debug

extension EditorPageViewModel: CustomDebugStringConvertible {
    var debugDescription: String {
        "\(String(reflecting: Self.self)) -> \(String(describing: document.objectId))"
    }
}
