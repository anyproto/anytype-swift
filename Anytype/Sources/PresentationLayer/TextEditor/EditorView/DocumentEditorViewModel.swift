import Foundation
import SwiftUI
import Combine
import os
import BlocksModels


class DocumentEditorViewModel: ObservableObject {
    weak private(set) var viewInput: EditorModuleDocumentViewInput?
    
    var document: BaseDocumentProtocol
    let modelsHolder: SharedBlockViewModelsHolder
    let blockDelegate: BlockDelegate
    
    let router: EditorRouterProtocol
    let objectSettingsViewModel: ObjectSettingsViewModel
    let detailsViewModel: DocumentDetailsViewModel
    let selectionHandler: EditorModuleSelectionHandlerProtocol
    let blockActionHandler: EditorActionHandlerProtocol
    
    private let blockBuilder: BlockViewModelBuilder
    private let blockActionsService = ServiceLocator.shared.blockActionsServiceSingle()
    
    private var subscriptions = Set<AnyCancellable>()
    private let documentId: BlockId

    // MARK: - Initialization
    init(
        documentId: BlockId,
        document: BaseDocumentProtocol,
        viewInput: EditorModuleDocumentViewInput,
        blockDelegate: BlockDelegate,
        objectSettinsViewModel: ObjectSettingsViewModel,
        detailsViewModel: DocumentDetailsViewModel,
        selectionHandler: EditorModuleSelectionHandlerProtocol,
        router: EditorRouterProtocol,
        modelsHolder: SharedBlockViewModelsHolder,
        blockBuilder: BlockViewModelBuilder,
        blockActionHandler: EditorActionHandler
    ) {
        self.documentId = documentId
        self.selectionHandler = selectionHandler
        self.objectSettingsViewModel = objectSettinsViewModel
        self.detailsViewModel = detailsViewModel
        self.viewInput = viewInput
        self.document = document
        self.router = router
        self.modelsHolder = modelsHolder
        self.blockBuilder = blockBuilder
        self.blockActionHandler = blockActionHandler
        self.blockDelegate = blockDelegate
        
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
        document.updateBlockModelPublisher
            .receiveOnMain()
            .sink { [weak self] updateResult in
                self?.handleUpdate(updateResult: updateResult)
            }.store(in: &self.subscriptions)
    }
    
    private func handleUpdate(updateResult: BaseDocumentUpdateResult) {
        switch updateResult.updates {
        case .general:
            let blocksViewModels = blockBuilder.build(updateResult.models, details: updateResult.details)
            updateBlocksViewModels(models: blocksViewModels)
            if let details = updateResult.details {
                updateDetails(details)
            }
        case let .details(newDetails):
            updateDetails(newDetails)
        case let .update(updatedIds):
            guard !updatedIds.isEmpty else {
                return
            }
            
            updateViewModelsWithStructs(updatedIds)
            viewInput?.updateRowsWithoutRefreshing(ids: updatedIds)
        }
    }
    
    private func updateDetails(_ details: DetailsData) {
        guard details.parentId == documentId else {
            return
        }
        
        objectSettingsViewModel.update(with: details)
        detailsViewModel.performUpdateUsingDetails(details)
    }
    
    private func updateViewModelsWithStructs(_ blockIds: Set<BlockId>) {
        guard !blockIds.isEmpty else {
            return
        }

        for blockId in blockIds {
            guard let newRecord = document.rootActiveModel?.findChild(by: blockId) else {
                assertionFailure("Could not find object with id: \(blockId)")
                return
            }
            
            guard let newModel = blockBuilder.build(newRecord, details: document.defaultDetailsActiveModel.currentDetails) else {
                assertionFailure("Could not build model from record: \(newRecord)")
                return
            }
            
            modelsHolder.models.enumerated()
                .first { $0.element.blockId == blockId }
                .flatMap { offset, data in
                    modelsHolder.models[offset] = newModel
                }
        }
    }

    private func updateBlocksViewModels(models: [BlockViewModelProtocol]) {
        let difference = models.difference(from: modelsHolder.models) { $0.diffable == $1.diffable }
        if !difference.isEmpty, let result = modelsHolder.models.applying(difference) {
            modelsHolder.models = result
            self.viewInput?.updateData(result)
        }
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
            assertionFailure("Row doesn't exist")
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

// MARK: - Debug

extension DocumentEditorViewModel: CustomDebugStringConvertible {
    var debugDescription: String {
        "\(String(reflecting: Self.self)) -> \(String(describing: document.documentId))"
    }
}
