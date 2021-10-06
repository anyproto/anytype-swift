import Foundation
import SwiftUI
import Combine
import os
import BlocksModels
import Amplitude
import AnytypeCore

final class EditorPageViewModel: EditorPageViewModelProtocol {
    weak private(set) var viewInput: EditorPageViewInput?
    
    let documentId: BlockId
    
    var document: BaseDocumentProtocol
    let modelsHolder: ObjectContentViewModelsSharedHolder
    let blockDelegate: BlockDelegate
    
    let router: EditorRouterProtocol
    
    private let objectHeaderLocalEventsListener = ObjectHeaderLocalEventsListener()
    let objectSettingsViewModel: ObjectSettingsViewModel
    let blockActionHandler: EditorActionHandlerProtocol
    let wholeBlockMarkupViewModel: MarkupViewModel
    
    private let blockBuilder: BlockViewModelBuilder
    private let blockActionsService = ServiceLocator.shared.blockActionsServiceSingle()
    private let headerBuilder: ObjectHeaderBuilder
    
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Initialization
    init(
        documentId: BlockId,
        document: BaseDocumentProtocol,
        viewInput: EditorPageViewInput,
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
        guard let result = blockActionsService.open(contextId: documentId, blockId: documentId) else {
            return
        }
        
        document.open(result)
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
            event,
            details: modelsHolder.details
        )
        
        viewInput?.update(header: header, details: modelsHolder.details)
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
            
            viewInput?.update(blocks: modelsHolder.models)
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
        
        let details = modelsHolder.details
        let header = headerBuilder.objectHeader(details: details)
        
        viewInput?.update(header: header, details: details)
        viewInput?.update(blocks: modelsHolder.models)
        
        if let details = details {
            objectSettingsViewModel.update(with: details)
        }
    }
    
}

// MARK: - View output

extension EditorPageViewModel {
    func viewLoaded() {
        Amplitude.instance().logEvent(
            AmplitudeEventsName.documentPage,
            withEventProperties: [AmplitudeEventsPropertiesKey.documentId: documentId]
        )
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
        "\(String(reflecting: Self.self)) -> \(String(describing: document.documentId))"
    }
}
