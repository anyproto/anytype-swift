import Foundation
import SwiftUI
import Combine
import os
import BlocksModels
import Amplitude
import AnytypeCore

final class DocumentEditorViewModel: DocumentEditorViewOutput {
    weak private(set) var viewInput: DocumentEditorViewInput?
    
    var document: BaseDocumentProtocol
    let modelsHolder: ObjectContentViewModelsSharedHolder
    let blockDelegate: BlockDelegate
    
    let router: EditorRouterProtocol
    
    let objectHeaderLocalEventsListener = ObjectHeaderLocalEventsListener()
    let objectSettingsViewModel: ObjectSettingsViewModel
    let selectionHandler: EditorModuleSelectionHandlerProtocol
    let blockActionHandler: EditorActionHandlerProtocol
    let wholeBlockMarkupViewModel: MarkupViewModel
    
    private let blockBuilder: BlockViewModelBuilder
    private let blockActionsService = ServiceLocator.shared.blockActionsServiceSingle()
    
    private var subscriptions = Set<AnyCancellable>()
    private let documentId: BlockId
    
    private lazy var onIconTap = {
        UISelectionFeedbackGenerator().selectionChanged()
        self.router.showIconPicker(viewModel: self.objectSettingsViewModel.iconPickerViewModel)
    }
    
    private lazy var onCoverTap = {
        UISelectionFeedbackGenerator().selectionChanged()
        self.router.showCoverPicker(viewModel: self.objectSettingsViewModel.coverPickerViewModel)
    }

    // MARK: - Initialization
    init(
        documentId: BlockId,
        document: BaseDocumentProtocol,
        viewInput: DocumentEditorViewInput,
        blockDelegate: BlockDelegate,
        objectSettinsViewModel: ObjectSettingsViewModel,
        selectionHandler: EditorModuleSelectionHandlerProtocol,
        router: EditorRouterProtocol,
        modelsHolder: ObjectContentViewModelsSharedHolder,
        blockBuilder: BlockViewModelBuilder,
        blockActionHandler: EditorActionHandler,
        wholeBlockMarkupViewModel: MarkupViewModel
    ) {
        self.documentId = documentId
        self.selectionHandler = selectionHandler
        self.objectSettingsViewModel = objectSettinsViewModel
        self.viewInput = viewInput
        self.document = document
        self.router = router
        self.modelsHolder = modelsHolder
        self.blockBuilder = blockBuilder
        self.blockActionHandler = blockActionHandler
        self.blockDelegate = blockDelegate
        self.wholeBlockMarkupViewModel = wholeBlockMarkupViewModel
        
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
        let header = modelsHolder.details?.objectHeader(onIconTap: onIconTap, onCoverTap: onCoverTap)
        
        guard let header = header else {
            let fakeHeader: ObjectHeader = {
                switch event {
                case .iconUploading(let uIImage):
                    return ObjectHeader.iconOnly(
                        ObjectIcon(
                            state: .preview(.basic(uIImage), .left),
                            onIconTap: onIconTap,
                            onCoverTap: onCoverTap
                        )
                    )
                case .coverUploading(let uIImage):
                    return ObjectHeader.coverOnly(
                        ObjectCover(state: .preview(uIImage), onTap: onCoverTap)
                    )
                }
            }()
            
            viewInput?.updateData(
                header: fakeHeader,
                blocks: modelsHolder.models
            )
            return
        }
        
        viewInput?.updateData(
            header: header.modifiedByLocalEvent(event, onIconTap: onIconTap, onCoverTap: onCoverTap) ?? .empty(ObjectHeaderEmptyData(onTap: onCoverTap)),
            blocks: modelsHolder.models
        )
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
            
            viewInput?.updateData(
                header: modelsHolder.details?.objectHeader(onIconTap: onIconTap, onCoverTap: onCoverTap) ??
                    .empty(ObjectHeaderEmptyData(onTap: onCoverTap)),
                blocks: modelsHolder.models
            )
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
            
            guard let newModel = blockBuilder.build(newRecord, details: document.defaultDetailsActiveModel.currentDetails) else {
                anytypeAssertionFailure("Could not build model from record: \(newRecord)")
                return
            }
            
            modelsHolder.models.enumerated()
                .first { $0.element.blockId == blockId }
                .flatMap { offset, data in
                    modelsHolder.models[offset] = newModel
                }
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

    private func handleGeneralUpdate(with details: DetailsData?, models: [BlockViewModelProtocol]) {
        modelsHolder.apply(newModels: models)
        modelsHolder.apply(newDetails: details)
        
        guard let details = modelsHolder.details else {
            viewInput?.updateData(
                header: .empty(ObjectHeaderEmptyData(onTap: onCoverTap)),
                blocks: modelsHolder.models
            )
            return
        }
        
        viewInput?.updateData(
            header: details.objectHeader(onIconTap: onIconTap, onCoverTap: onCoverTap),
            blocks: modelsHolder.models
        )
        
        objectSettingsViewModel.update(with: details)
    }
}

// MARK: - View output

extension DocumentEditorViewModel {
    func viewLoaded() {
        Amplitude.instance().logEvent(AmplitudeEventsName.documentPage,
                                      withEventProperties: [AmplitudeEventsPropertiesKey.documentId: documentId])
    }
}

// MARK: - Selection Handling

extension DocumentEditorViewModel {
    func didSelectBlock(at index: IndexPath) {
        if selectionHandler.selectionEnabled {
            didSelect(atIndex: index)
            return
        }
        element(at: index)?.didSelectRowInTableView()
    }

    private func element(at: IndexPath) -> BlockViewModelProtocol? {
        guard modelsHolder.models.indices.contains(at.row) else {
            anytypeAssertionFailure("Row doesn't exist")
            return nil
        }
        return modelsHolder.models[at.row]
    }

    private func didSelect(atIndex: IndexPath) {
        guard let item = element(at: atIndex) else { return }
        selectionHandler.set(
            selected: !selectionHandler.selected(id: item.blockId),
            id: item.blockId,
            type: item.content.type
        )
    }
}

extension DocumentEditorViewModel {
    func showSettings() {
        router.showSettings(settingsViewModel: objectSettingsViewModel)
    }
}

// MARK: - Debug

extension DocumentEditorViewModel: CustomDebugStringConvertible {
    var debugDescription: String {
        "\(String(reflecting: Self.self)) -> \(String(describing: document.documentId))"
    }
}
