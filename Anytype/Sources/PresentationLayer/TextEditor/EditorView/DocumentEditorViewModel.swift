import Foundation
import SwiftUI
import Combine
import os
import BlocksModels


class DocumentEditorViewModel: ObservableObject {
    weak var viewInput: EditorModuleDocumentViewInput?
    var router: EditorRouterProtocol!
    
    private(set) lazy var settingViewModel = DocumentSettingViewModel(
        detailsActiveModel: document.defaultDetailsActiveModel
    )
    
    let document: BaseDocumentProtocol = BaseDocument()

    /// Service
    private let blockActionsService = ServiceLocator.shared.blockActionsServiceSingle()
    private lazy var blocksConverter = CompoundViewModelConverter(document: document, blockActionHandler: self)

    private(set) var documentIcon: DocumentIcon?
    private(set) var documentCover: DocumentCover?
    
    private lazy var blockActionHandler = BlockActionHandler(
        documentId: document.documentId,
        documentViewInteraction: self,
        selectionHandler: selectionHandler,
        document: document,
        router: router
    )
    
    // Combine Subscriptions
    private var subscriptions = Set<AnyCancellable>()

    let selectionHandler: EditorModuleSelectionHandlerProtocol

    /// Builders to build block views
    @Published private(set) var blocksViewModels: [BaseBlockViewModel] = [] {
        didSet {
            if self.blocksViewModels.isEmpty {
                selectionHandler.selectionEnabled = false
            }
        }
    }

    let updateElementsSubject = PassthroughSubject<Set<BlockId>, Never>()
    lazy var updateElementsPublisher: AnyPublisher<Set<BlockId>, Never> = updateElementsSubject.eraseToAnyPublisher()
    

    // MARK: - Initialization
    init(
        documentId: BlockId,
        selectionHandler: EditorModuleSelectionHandlerProtocol
    ) {
        self.selectionHandler = selectionHandler
        
        obtainDocument(documentId: documentId)
    }

    private func obtainDocument(documentId: String) {
        blockActionsService.open(contextID: documentId, blockID: documentId)
            .receiveOnMain()
            .sinkWithDefaultCompletion("Open document with id: \(documentId)") { [weak self] value in
                self?.handleOpenDocument(value)
            }.store(in: &self.subscriptions)
    }

    private func handleOpenDocument(_ value: ServiceSuccess) {
        document.updateBlockModelPublisher
            .receiveOnMain()
            .sink { [weak self] updateResult in
                guard let self = self else { return }
                
                switch updateResult.updates {
                case .general:
                    let blocksViewModels = self.blocksConverter.convert(
                        updateResult.models,
                        router: self.router,
                        editorViewModel: self
                    )
                    self.update(blocksViewModels: blocksViewModels)
                case let .update(update):
                    if update.updatedIds.isEmpty {
                        return
                    }
                    self.updateElementsSubject.send(update.updatedIds)
                }
            }.store(in: &self.subscriptions)
            
        document.open(value)
        
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

    private func update(blocksViewModels: [BaseBlockViewModel]) {
        let difference = blocksViewModels.difference(from: self.blocksViewModels) { $0.diffable == $1.diffable }
        if !difference.isEmpty, let result = self.blocksViewModels.applying(difference) {
            self.blocksViewModels = result
            self.viewInput?.updateData(result)
        }
    }
}

// MARK: - Reactions

private extension DocumentEditorViewModel {

    func process(events: PackOfEvents) {
        events.ourEvents.forEach { event in
            switch event {
            case let .setFocus(blockId, position):
                if let blockViewModel = blocksViewModels.first(where: { $0.blockId == blockId }) as? TextBlockViewModel {
                    blockViewModel.set(focus: position)
                }
            default: return
            }
        }
        document.handle(events: events)
    }
}

// MARK: - On Tap Gesture

extension DocumentEditorViewModel {
    func handlingTapOnEmptySpot() {
        guard let block = document.rootActiveModel?.blockModel, let parentId = document.documentId else {
            return
        }
        handleAction(.createEmptyBlock(parentId: parentId), model: block)
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

    private func element(at: IndexPath) -> BaseBlockViewModel? {
        guard self.blocksViewModels.indices.contains(at.row) else {
            assertionFailure("Row doesn't exist")
            return nil
        }
        return self.blocksViewModels[at.row]
    }

    private func didSelect(atIndex: IndexPath) {
        guard let item = element(at: atIndex) else { return }
        selectionHandler.set(
            selected: !selectionHandler.selected(id: item.blockId),
            id: item.blockId,
             type: item.block.content.type
        )
    }
}

// MARK: - Debug

extension DocumentEditorViewModel: CustomDebugStringConvertible {
    var debugDescription: String {
        "\(String(reflecting: Self.self)) -> \(String(describing: document.documentId))"
    }
}

// MARK: - Base block delegate

extension DocumentEditorViewModel: BaseBlockDelegate {

    func blockSizeChanged() {
        viewInput?.needsUpdateLayout()
    }

    func becomeFirstResponder(for block: BlockModelProtocol) {
        document.userSession?.setFirstResponder(with: block)
    }

    func didBeginEditing() {
        viewInput?.textBlockDidBeginEditing()
    }

    func willBeginEditing() {
        viewInput?.textBlockWillBeginEditing()
    }
}

protocol NewBlockActionHandler: AnyObject {
    func handleAction(_ action: BlockHandlerActionType, model: BlockModelProtocol)
    func handleActionForFirstResponder(_ action: BlockHandlerActionType)
    func handleActionWithoutCompletion(_ action: BlockHandlerActionType, model: BlockModelProtocol)
    
    func upload(blockId: BlockId, filePath: String)
}

extension DocumentEditorViewModel: NewBlockActionHandler {
    /// Block action handler
    func handleActionForFirstResponder(_ action: BlockHandlerActionType) {
        guard let firstResponder = document.userSession?.firstResponder() else {
            assertionFailure("No first responder for action \(action)")
            return
        }
        
        handleAction(action, model: firstResponder)
    }
    
    func handleAction(_ action: BlockHandlerActionType, model: BlockModelProtocol) {
        blockActionHandler?.handleBlockAction(action, block: model) { [weak self] events in
            self?.process(events: events)
        }
    }
    
    func upload(blockId: BlockId, filePath: String) {
        blockActionHandler?.upload(blockId: blockId, filePath: filePath)
    }
    
    
    func handleActionWithoutCompletion(_ action: BlockHandlerActionType, model: BlockModelProtocol) {
        blockActionHandler?.handleBlockAction(action, block: model, completion: nil)
    }
}

// MARK: - EditorModuleSelectionHandlerHolderProtocol

extension DocumentEditorViewModel: EditorModuleSelectionHandlerHolderProtocol {
    func selectAll() {
        let ids = self.blocksViewModels.dropFirst().reduce(into: [BlockId: BlockContentType]()) { result, model in
            result[model.blockId] = model.block.content.type
        }
        selectionHandler.select(ids: ids)
    }
}
