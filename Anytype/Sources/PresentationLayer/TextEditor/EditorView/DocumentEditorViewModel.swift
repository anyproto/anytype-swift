import Foundation
import SwiftUI
import Combine
import os
import BlocksModels


class DocumentEditorViewModel: ObservableObject {
    private(set) var documentIcon: DocumentIcon?
    private(set) var documentCover: DocumentCover?
    
    weak private(set) var viewInput: EditorModuleDocumentViewInput?
    
    var document: BaseDocumentProtocol
    let modelsHolder: SharedBlockViewModelsHolder
    let blockDelegate: BlockDelegate
    
    let router: EditorRouterProtocol
    let settingsViewModel: DocumentSettingsViewModel
    let selectionHandler: EditorModuleSelectionHandlerProtocol
    let blockActionHandler: EditorActionHandlerProtocol
    
    private let blocksConverter: CompoundViewModelConverter
    private let blockActionsService = ServiceLocator.shared.blockActionsServiceSingle()
    
    private var subscriptions = Set<AnyCancellable>()
    
    private let updateElementsSubject: PassthroughSubject<Set<BlockId>, Never>
    lazy var updateElementsPublisher: AnyPublisher<Set<BlockId>, Never> = updateElementsSubject.eraseToAnyPublisher()

    // MARK: - Initialization
    init(
        documentId: BlockId,
        document: BaseDocumentProtocol,
        viewInput: EditorModuleDocumentViewInput,
        blockDelegate: BlockDelegate,
        settingsViewModel: DocumentSettingsViewModel,
        selectionHandler: EditorModuleSelectionHandlerProtocol,
        router: EditorRouterProtocol,
        modelsHolder: SharedBlockViewModelsHolder,
        updateElementsSubject: PassthroughSubject<Set<BlockId>, Never>,
        blocksConverter: CompoundViewModelConverter,
        blockActionHandler: EditorActionHandler
    ) {
        self.selectionHandler = selectionHandler
        self.settingsViewModel = settingsViewModel
        self.viewInput = viewInput
        self.document = document
        self.router = router
        self.modelsHolder = modelsHolder
        self.updateElementsSubject = updateElementsSubject
        self.blocksConverter = blocksConverter
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
        
        document.pageDetailsPublisher()
            .safelyUnwrapOptionals()
            .receiveOnMain()
            .sink { [weak self] detailsProvider in
                guard let self = self else { return }
                
                self.documentIcon = detailsProvider.documentIcon
                self.documentCover = detailsProvider.documentCover
                
                self.viewInput?.updateHeader()
            }
            .store(in: &subscriptions)
    }
    
    private func handleUpdate(updateResult: BaseDocumentUpdateResult) {
        switch updateResult.updates {
        case .general:
            let blocksViewModels = blocksConverter.convert(updateResult.models)
            update(blocksViewModels: blocksViewModels)
        case let .update(update):
            if update.updatedIds.isEmpty {
                return
            }
            updateElementsSubject.send(update.updatedIds)
        }
    }

    private func update(blocksViewModels: [BlockViewModelProtocol]) {
        let difference = blocksViewModels.difference(from: modelsHolder.models) { $0.diffable == $1.diffable }
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
