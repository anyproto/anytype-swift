import Foundation
import SwiftUI
import Combine
import os
import BlocksModels


class DocumentEditorViewModel: ObservableObject {
    /// View Input
    weak var viewInput: EditorModuleDocumentViewInput?
    /// Router for current page
    var editorRouter: EditorRouterProtocol?
    
    let document: BaseDocumentProtocol = BaseDocument()

    /// Service
    private let blockActionsService = ServiceLocator.shared.blockActionsServiceSingle()
    private lazy var blocksConverter = CompoundViewModelConverter(document: document)

    /// DocumentDetailsViewModel
    private(set) var detailsViewModel: DocumentDetailsViewModel?
    
    /// User Interaction Processor
    private lazy var oldblockActionHandler = BlockActionsHandlersFacade(documentViewInteraction: self)
    private let listBlockActionHandler = ListBlockActionHandler()
    private lazy var blockActionHandler = BlockActionHandler(
        documentId: document.documentId,
        documentViewInteraction: self
    )
    
    // Combine Subscriptions
    private var subscriptions = Set<AnyCancellable>()

    let selectionHandler: EditorModuleSelectionHandlerProtocol

    private var listToolbarSubject: PassthroughSubject<BlocksViews.Toolbar.UnderlyingAction, Never> = .init()

    private let publicUserActionSubject: PassthroughSubject<BlocksViews.UserAction, Never> = .init()
    lazy var publicUserActionPublisher: AnyPublisher<BlocksViews.UserAction, Never> = { self.publicUserActionSubject.eraseToAnyPublisher() }()

    private var publicActionsPayloadSubject: PassthroughSubject<BaseBlockViewModel.ActionsPayload, Never> = .init()
    lazy var publicActionsPayloadPublisher: AnyPublisher<BaseBlockViewModel.ActionsPayload, Never> = { self.publicActionsPayloadSubject.eraseToAnyPublisher() }()

    private var publicSizeDidChangeSubject: PassthroughSubject<Void, Never> = .init()
    lazy private(set) var publicSizeDidChangePublisher: AnyPublisher<Void, Never> = { self.publicSizeDidChangeSubject.eraseToAnyPublisher() }()

    private var listActionsPayloadSubject: PassthroughSubject<Toolbar, Never> = .init()
    lazy private var listActionsPayloadPublisher: AnyPublisher<Toolbar, Never> = {
        self.listActionsPayloadSubject.eraseToAnyPublisher()
    }()

    @Published var error: String?

    /// Builders to build block views
    @Published private(set) var blocksViewModels: [BaseBlockViewModel] = [] {
        didSet {
            if self.blocksViewModels.isEmpty {
                self.set(selectionEnabled: false)
            }
        }
    }
    
    private var internalState: State = .loading
    var state: State {
        switch self.internalState {
        case .loading: return .loading
        default: return self.blocksViewModels.isEmpty ? .empty : .ready
        }
    }

    /// We should update some items in place.
    /// For that, we use this subject which send events that some items are just updated, not removed or deleted.
    /// Its `Output` is a `List<BlockId>`
    private let updateElementsSubject: PassthroughSubject<Set<BlockId>, Never> = .init()
    private(set) var updateElementsPublisher: AnyPublisher<Set<BlockId>, Never> = .empty()
    private var lastSetTextClosure: (() -> Void)?
    
    // Used for subscription storage
    private let selectionPresenter: EditorSelectionToolbarPresenter

    // MARK: - Initialization
    init(
        documentId: BlockId,
        selectionHandler: EditorModuleSelectionHandlerProtocol,
        selectionPresenter: EditorSelectionToolbarPresenter
    ) {
        self.selectionHandler = selectionHandler
        self.selectionPresenter = selectionPresenter
        
        selectionPresenter.userAction.sink { [weak self] (value) in
            self?.process(value)
        }.store(in: &self.subscriptions)
        
        self.setupSubscriptions()

        // TODO: Deprecated.
        // We should rename it.
        // Our case would be the following
        // We should expose one publisher that will publish different updates (delete/update/add) to outer world.
        // Or to our view controller.
        // Maybe it will publish only resulted collection of elements.
        self.updateElementsPublisher = self.updateElementsSubject.eraseToAnyPublisher()

        self.obtainDocument(documentId: documentId)
    }
    
    func setNavigationItem(_ item: UINavigationItem?) {
        selectionPresenter.navigationItem = item
    }

    /// Apply last setText action, to ensure text was saved after document was closed
    func applyPendingChanges() {
        self.lastSetTextClosure?()
    }

    // MARK: - Setup subscriptions

    private func setupSubscriptions() {
        self.publicActionsPayloadPublisher.sink { [weak self] (value) in
            self?.process(actionsPayload: value)
        }.store(in: &self.subscriptions)

        _ = self.oldblockActionHandler.configured(self.publicActionsPayloadPublisher)

        self.listToolbarSubject.sink { [weak self] (value) in
            self?.process(toolbarAction: value)
        }.store(in: &self.subscriptions)

        _ = self.listBlockActionHandler.configured(self.listActionsPayloadPublisher)

        self.oldblockActionHandler.reactionPublisher.sink { [weak self] (value) in
            self?.process(reaction: value)
        }.store(in: &self.subscriptions)

        self.listBlockActionHandler.reactionPublisher.sink { [weak self] (value) in
            self?.process(reaction: value)
        }.store(in: &self.subscriptions)

        self.$blocksViewModels.sink { [weak self] value in
            self?.enhanceUserActionsAndPayloads(value)
        }.store(in: &self.subscriptions)
    }

    private func obtainDocument(documentId: String?) {
        guard let documentId = documentId else { return }
        self.internalState = .loading

        self.blockActionsService.open(contextID: documentId, blockID: documentId)
            .receiveOnMain()
            .sink(receiveCompletion: { [weak self] (value) in
                switch value {
                case .finished: break
                case let .failure(error):
                    self?.internalState = .empty
                    self?.error = error.localizedDescription
                }
            }, receiveValue: { [weak self] value in
                self?.handleOpenDocument(value)
            }).store(in: &self.subscriptions)
    }

    private func handleOpenDocument(_ value: ServiceSuccess) {
        document.updateBlockModelPublisher
            .receiveOnMain()
            .sink { [weak self] updateResult in
                guard let self = self else { return }
                
                switch updateResult.updates {
                case .general:
                    let blocksViewModels = self.blocksConverter.convert(updateResult.models, router: self.editorRouter)
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
                self?.updateDetailsViewModel(with: detailsProvider)

                let blocksViewModelsToUpdate = self?.blocksViewModels.first(where: { blockViewModel in
                    blockViewModel.information.content.type == .text(.title)
                })
                blocksViewModelsToUpdate?.updateView()
                self?.viewInput?.refreshViewLayout()
            }
            .store(in: &subscriptions)

        self.configureInteractions(document.documentId)
    }

    private func update(blocksViewModels: [BaseBlockViewModel]) {
        let difference = blocksViewModels.difference(from: self.blocksViewModels) {$0.diffable == $1.diffable}
        if !difference.isEmpty, let result = self.blocksViewModels.applying(difference) {
            self.blocksViewModels = result
            self.viewInput?.updateData(result)
        }
    }
    
    private func updateDetailsViewModel(with detailsProvider: DetailsEntryValueProvider) {
        let iconViewModel: DocumentIconViewModel? = detailsProvider.documentIcon.flatMap {
            DocumentIconViewModel(
                documentIcon: $0,
                detailsActiveModel: self.document.defaultDetailsActiveModel,
                userActionSubject: self.publicUserActionSubject
            )
        }
        let coverViewModel: DocumentCoverViewModel? = detailsProvider.documentCover.flatMap {
            DocumentCoverViewModel(
                cover: $0,
                detailsActiveModel: self.document.defaultDetailsActiveModel,
                userActionSubject: self.publicUserActionSubject
            )
        }
        
        self.detailsViewModel = DocumentDetailsViewModel(
            iconViewModel: iconViewModel,
            coverViewModel: coverViewModel
        )
    }

    private func configureInteractions(_ documentId: BlockId?) {
        guard let documentId = documentId else {
            assertionFailure("configureInteractions(_:). DocumentId is not configured.")
            return
        }
        _ = self.oldblockActionHandler.configured(documentId: documentId).configured(self)
        _ = self.listBlockActionHandler.configured(documentId: documentId)
    }
    
}

// MARK: - DocumentViewInteraction

extension DocumentEditorViewModel: DocumentViewInteraction {
    func updateBlocks(with ids: Set<BlockId>) {
        self.updateElementsSubject.send(ids)
    }
}

// MARK: - Reactions

private extension DocumentEditorViewModel {
    func process(reaction: BlockActionService.Reaction) {
        switch reaction {
        case let .shouldHandleEvent(value):

            value.events.ourEvents.forEach { event in
                switch event {
                case let .setFocus(focus):
                    if let blockViewModel = blocksViewModels.first(where: { $0.blockId == focus.blockId }) as? TextBlockViewModel {
                        blockViewModel.set(focus: focus.position ?? .end)
                    }
                default: return
                }
            }

            let events = value.events
            document.handle(events: events)
        default: return
        }
    }

    func process(reaction: ListBlockActionHandler.Reaction) {
        switch reaction {
        case let .shouldHandleEvent(value):
            let events = value.payload.events
            document.handle(events: events)
        }
    }
}

// MARK: - On Tap Gesture

extension DocumentEditorViewModel {
    func handlingTapIfEmpty() {
        oldblockActionHandler.createEmptyBlock(
            listIsEmpty: state == .empty, parentModel: document.rootActiveModel
        )
    }
}

// MARK: - Selection Handling

extension DocumentEditorViewModel {
    func didSelectBlock(at index: IndexPath) {
        if self.selectionEnabled() {
            self.didSelect(atIndex: index)
            return
        }
        self.element(at: index)?.receive(event: .didSelectRowInTableView)
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
        self.set(selected: !self.selected(id: item.blockId),
                 id: item.blockId,
                 type: item.getBlock().content.type)
    }
}

// MARK: - Process actions

private extension DocumentEditorViewModel {
    func process(actionsPayload: BaseBlockViewModel.ActionsPayload) {
        switch actionsPayload {
        case let .textView(value):
            switch value.action {
            case .textView(.showMultiActionMenuAction):
                self.set(selectionEnabled: true)
            case let .textView(.changeCaretPosition(selectedRange)):
                document.userSession?.setFocusAt(position: .at(selectedRange))
            default: return
            }
        // TODO: we need coordinator(router) here that show this view https://app.clickup.com/t/h13ytp
        case let .showCodeLanguageView(languages, completion):
            viewInput?.showCodeLanguageView(with: languages, completion: completion)
        case let .showStyleMenu(blockModel, blockViewModel):
            viewInput?.showStyleMenu(blockModel: blockModel, blockViewModel: blockViewModel)
        case let .becomeFirstResponder(blockModel):
            document.userSession?.setFirstResponder(with: blockModel)
        case .toolbar, .marksPane, .userAction: return
        }
    }

    func process(_ value: EditorSelectionToolbarPresenter.SelectionAction) {
        switch value {
        case let .selection(value):
            switch value {
            case let .selectAll(value):
                switch value {
                case .selectAll: self.selectAll()
                case .deselectAll: self.deselectAll()
                }
            case .done(.done): self.set(selectionEnabled: false)
            }
        case let .toolbar(value):
            let selectedIds = self.list()
            switch value {
            case let .turnInto(payload):
                publicUserActionSubject.send(
                    .toolbars(
                        .turnIntoBlock(
                            .init(output: self.listToolbarSubject, input: payload)
                        )
                    )
                )
            case .delete:
                listActionsPayloadSubject.send(
                    Toolbar(model: selectedIds, action: .editBlock(.delete))
                )
            case .copy:
                break
            }
        }
    }

    func process(toolbarAction: BlocksViews.Toolbar.UnderlyingAction) {
        listActionsPayloadSubject.send(
            Toolbar(
                model: self.list(),
                action: toolbarAction
            )
        )
    }
}

extension DocumentEditorViewModel {
    
    struct Toolbar {
        let model: [BlockId]
        let action: BlocksViews.Toolbar.UnderlyingAction
    }
    
}


// MARK: - Debug
extension DocumentEditorViewModel: CustomDebugStringConvertible {
    var debugDescription: String {
        "\(String(reflecting: Self.self)) -> \(String(describing: document.documentId))"
    }
}

// MARK: - Enhance UserActions and Payloads

/// These methods work in opposite way as `Merging`.
/// Instead, we just set a "delegate" ( no, our Subject ) to all viewModels in a List.
/// So, we have different approach.
///
/// 1. We have one Subject that we give to all ViewModels.
///
extension DocumentEditorViewModel {
    func enhanceUserActionsAndPayloads(_ builders: [BaseBlockViewModel]) {
        builders.forEach { block in
            block.configured(userActionSubject: publicUserActionSubject)
            block.configured(actionsPayloadSubject: publicActionsPayloadSubject)
            block.configured(sizeDidChangeSubject: publicSizeDidChangeSubject)
        }
    }
    
}

// MARK: - Public methods for view controller

extension DocumentEditorViewModel {

    /// Block action handler
    func handleAction(_ action: BlockActionHandler.ActionType) {
        guard let firstResponder = document.userSession?.firstResponder() else { return }
        
        blockActionHandler?.handleBlockAction(action, block: firstResponder) { [weak self] actionType, events in
            self?.process(
                reaction: .shouldHandleEvent(
                    .init(actionType: actionType,
                          events: events
                    )
                )
            )
        }
    }
}

extension DocumentEditorViewModel: EditorModuleSelectionHandlerHolderProtocol {
    func selectAll() {
        let ids = self.blocksViewModels.dropFirst().reduce(into: [BlockId: BlockContentType]()) { result, model in
            result[model.blockId] = model.getBlock().content.type
        }
        self.select(ids: ids)
    }
}
