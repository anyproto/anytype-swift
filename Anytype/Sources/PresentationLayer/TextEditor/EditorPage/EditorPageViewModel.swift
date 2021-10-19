import Foundation
import SwiftUI
import Combine
import os
import BlocksModels
import Amplitude
import AnytypeCore

final class EditorPageViewModel: EditorPageViewModelProtocol {
    weak private(set) var viewInput: EditorPageViewInput?
    
    let document: BaseDocumentProtocol
    let modelsHolder: ObjectContentViewModelsSharedHolder
    let blockDelegate: BlockDelegate
    
    let router: EditorRouterProtocol
    
    private let objectHeaderLocalEventsListener = ObjectHeaderLocalEventsListener()
    let objectSettingsViewModel: ObjectSettingsViewModel
    let blockActionHandler: EditorActionHandlerProtocol
    let wholeBlockMarkupViewModel: MarkupViewModel
    
    private let blockBuilder: BlockViewModelBuilder
    private let headerBuilder: ObjectHeaderBuilder

    private var didAppearedOnce = false

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
        headerBuilder: ObjectHeaderBuilder
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
        
        setupSubscriptions()
    }

    private func setupSubscriptions() {
        objectHeaderLocalEventsListener.beginObservingEvents { [weak self] event in
            self?.handleObjectHeaderLocalEvent(event)
        }
        
        document.onUpdateReceive = { [weak self] updateResult in
            self?.handleUpdate(updateResult: updateResult)
            
        }
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
                // TODO: - call blocks update to update mentions/links
                performGeneralUpdate()
                return
            }
            
            let details = document.objectDetails
            let header = headerBuilder.objectHeader(details: details)
            
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
        let models = document.flattenBlocks
        
        let blocksViewModels = blockBuilder.build(
            models,
            currentObjectDetails: document.objectDetails
        )
        
        handleGeneralUpdate(
            with: blocksViewModels
        )
        
        updateMarkupViewModel(newBlockViewModels: blocksViewModels)
    }
    
    private func updateViewModelsWithStructs(_ blockIds: Set<BlockId>) {
        guard !blockIds.isEmpty else {
            return
        }

        for blockId in blockIds {
            guard
                let newRecord = document.blocksContainer.model(
                    id: document.objectId
                )?.container?.model(id: blockId) else {
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
                    currentObjectDetails: document.objectDetails,
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
            withEventProperties: [AmplitudeEventsPropertiesKey.documentId: document.objectId]
        )
        document.open()
    }

    func viewAppeared() {
        if !didAppearedOnce,
           let firstModel = modelsHolder.models.first,
           firstModel.content.isEmpty {
            (firstModel as? TextBlockViewModel)?.set(focus: .beginning)
        }

        didAppearedOnce = true
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
