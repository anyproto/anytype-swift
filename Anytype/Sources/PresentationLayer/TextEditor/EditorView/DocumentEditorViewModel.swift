import Foundation
import SwiftUI
import Combine
import os
import BlocksModels
import Amplitude
import AnytypeCore

final class DocumentEditorViewModel: DocumentEditorViewModelProtocol {
    weak private(set) var viewInput: DocumentEditorViewInput?
    
    var document: BaseDocumentProtocol
    let modelsHolder: ObjectContentViewModelsSharedHolder
    let blockDelegate: BlockDelegate
    
    let router: EditorRouterProtocol
    
    let objectHeaderLocalEventsListener = ObjectHeaderLocalEventsListener()
    let objectSettingsViewModel: ObjectSettingsViewModel
    let blockActionHandler: EditorActionHandlerProtocol
    let wholeBlockMarkupViewModel: MarkupViewModel
    
    private let blockBuilder: BlockViewModelBuilder
    private let blockActionsService = ServiceLocator.shared.blockActionsServiceSingle()
    private let headerBuilder: ObjectHeaderBuilder
    
    private var subscriptions = Set<AnyCancellable>()
    private let documentId: BlockId

    // MARK: - Initialization
    init(
        documentId: BlockId,
        document: BaseDocumentProtocol,
        viewInput: DocumentEditorViewInput,
        blockDelegate: BlockDelegate,
        objectSettinsViewModel: ObjectSettingsViewModel,
        router: EditorRouterProtocol,
        modelsHolder: ObjectContentViewModelsSharedHolder,
        blockBuilder: BlockViewModelBuilder,
        blockActionHandler: EditorActionHandler,
        wholeBlockMarkupViewModel: MarkupViewModel,
        headerBuilder: ObjectHeaderBuilder
    ) {
        self.documentId = documentId
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
        
        setupSubscriptions()
        obtainDocument(documentId: documentId)
    }

    private func obtainDocument(documentId: String) {
        blockActionsService.open(contextID: documentId, blockID: documentId)
            .receiveOnMain()
            .sinkWithDefaultCompletion("Open document with id: \(documentId)") { [weak self] value in
                self?.document.open(value)
            }.store(in: &self.subscriptions)
    }

    private func setupSubscriptions() {
        objectHeaderLocalEventsListener.beginObservingEvents { [weak self] event in
            self?.handleObjectHeaderLocalEvent(event)
        }
        
        document.updateBlockModelPublisher
            .receiveOnMain()
            .sink { [weak self] updateResult in
                self?.handleUpdate(updateResult: updateResult)
            }.store(in: &self.subscriptions)
    }
    
    private func handleObjectHeaderLocalEvent(_ event: ObjectHeaderLocalEvent) {
        let header = headerBuilder.objectHeaderForLocalEvent(
            details: modelsHolder.details,
            event: event
        )
        
        viewInput?.updateHeader(header, details: modelsHolder.details)
        viewInput?.updateBlocks(modelsHolder.models)
    }
    
    private func handleUpdate(updateResult: BaseDocumentUpdateResult) {
        switch updateResult.updates {
        case .general:
            let blocksViewModels = blockBuilder.build(updateResult.models, details: updateResult.details)
            
            handleGeneralUpdate(
                with: updateResult.details,
                models: blocksViewModels
            )
            
            updateMarkupViewModel(newBlockViewModels: blocksViewModels)
        case let .details(newDetails):
            handleGeneralUpdate(
                with: newDetails,
                models: modelsHolder.models
            )
        case let .update(updatedIds):
            guard !updatedIds.isEmpty else {
                return
            }
            
            updateViewModelsWithStructs(updatedIds)
            updateMarkupViewModel(updatedIds)
            
            viewInput?.updateBlocks(modelsHolder.models)
        }
    }
    
    private func updateViewModelsWithStructs(_ blockIds: Set<BlockId>) {
        guard !blockIds.isEmpty else {
            return
        }

        for blockId in blockIds {
            guard let newRecord = document.rootActiveModel?.container?.model(id: blockId) else {
                anytypeAssertionFailure("Could not find object with id: \(blockId)")
                return
            }

            let viewModelIndex = modelsHolder.models.firstIndex {
                $0.blockId == blockId
            }

            guard let viewModelIndex = viewModelIndex else {
                return
            }

            let upperBlock = modelsHolder.models[viewModelIndex].upperBlock
            
            guard let newModel = blockBuilder.build(
                    newRecord,
                    details: document.defaultDetailsActiveModel.currentDetails,
                    previousBlock: upperBlock
            )
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
        let container = document.rootActiveModel?.container
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

    private func handleGeneralUpdate(with details: DetailsDataProtocol?, models: [BlockViewModelProtocol]) {
        modelsHolder.apply(newModels: models)
        modelsHolder.apply(newDetails: details)
        
        updateView()
        
        if let details = modelsHolder.details {
            objectSettingsViewModel.update(with: details)
        }
    }
    
    func updateView() {
        let details = modelsHolder.details
        let header = headerBuilder.objectHeader(details: details)
        
        viewInput?.updateHeader(header, details: details)
        viewInput?.updateBlocks(modelsHolder.models)
    }
    
}

// MARK: - View output

extension DocumentEditorViewModel {
    func viewLoaded() {
        Amplitude.instance().logEvent(
            AmplitudeEventsName.documentPage,
            withEventProperties: [AmplitudeEventsPropertiesKey.documentId: documentId]
        )
    }
}

// MARK: - Selection Handling

extension DocumentEditorViewModel {
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

extension DocumentEditorViewModel {
    
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

extension DocumentEditorViewModel: CustomDebugStringConvertible {
    var debugDescription: String {
        "\(String(reflecting: Self.self)) -> \(String(describing: document.documentId))"
    }
}
