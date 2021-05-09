import Foundation
import SwiftUI
import Combine
import os
import BlocksModels


extension DocumentEditorViewModel {
    enum State {
        case loading
        case empty
        case ready
    }
    var state: State {
        switch self.internalState {
        case .loading: return .loading
        default: return self.builders.isEmpty ? .empty : .ready
        }
    }
}

// MARK: Events
extension DocumentEditorViewModel {
    enum UserEvent {
        case pageDetailsViewModelsDidSet
    }
}
    
class DocumentEditorViewModel: ObservableObject {
    typealias BlocksUserAction = BlocksViews.UserAction

    /// View Input
    weak var viewInput: EditorModuleDocumentViewInput?

    /// Service
    private var blockActionsService: BlockActionsServiceSingle = .init()

    /// Document ViewModel
    private(set) var documentViewModel: DocumentViewModelProtocol = DocumentViewModel()

    /// User Interaction Processor
    private lazy var blockActionHandler: BlockActionsHandlersFacade = .init(documentViewInteraction: self)
    private var listBlockActionHandler: ListBlockActionHandler = .init()

    /// Combine Subscriptions
    private var subscriptions: Set<AnyCancellable> = .init()

    /// Selection Handler
    private(set) var selectionHandler: EditorModuleSelectionHandlerProtocol?

    private var listToolbarSubject: PassthroughSubject<BlocksViews.Toolbar.UnderlyingAction, Never> = .init()

    private var publicUserActionSubject: PassthroughSubject<BlocksUserAction, Never> = .init()
    lazy var publicUserActionPublisher: AnyPublisher<BlocksUserAction, Never> = { self.publicUserActionSubject.eraseToAnyPublisher() }()

    private var publicActionsPayloadSubject: PassthroughSubject<BaseBlockViewModel.ActionsPayload, Never> = .init()
    lazy var publicActionsPayloadPublisher: AnyPublisher<BaseBlockViewModel.ActionsPayload, Never> = { self.publicActionsPayloadSubject.eraseToAnyPublisher() }()

    private var publicSizeDidChangeSubject: PassthroughSubject<Void, Never> = .init()
    lazy private(set) var publicSizeDidChangePublisher: AnyPublisher<Void, Never> = { self.publicSizeDidChangeSubject.eraseToAnyPublisher() }()

    private var listActionsPayloadSubject: PassthroughSubject<ActionsPayload, Never> = .init()
    lazy private var listActionsPayloadPublisher: AnyPublisher<ActionsPayload, Never> = {
        self.listActionsPayloadSubject.eraseToAnyPublisher()
    }()

    @Published var error: String?

    // MARK: Events
    @Published var userEvent: UserEvent?

    // MARK: Page View Models
    /// We need this model to be Published cause need handle actions from IconEmojiBlock
    typealias PageDetailsViewModelsDictionary = [BaseDocument.DetailsContentKind : BlockViewBuilderProtocol]
    @available(iOS, introduced: 13.0, deprecated: 14.0, message: "This property make sense only before real model was presented. Remove it.")
    lazy private(set) var detailsViewModels: PageDetailsViewModelsDictionary = [:] {
        didSet {
            self.enhanceDetails(self.detailsViewModels)
            self.userEvent = .pageDetailsViewModelsDidSet
        }
    }

    /// Builders to build block views
    @Published private(set) var builders: [BaseBlockViewModel] = [] {
        didSet {
            if self.builders.isEmpty {
                self.set(selectionEnabled: false)
            }
        }
    }
    private var internalState: State = .loading

    /// We should update some items in place.
    /// For that, we use this subject which send events that some items are just updated, not removed or deleted.
    /// Its `Output` is a `List<BlockId>`
    private let updateElementsSubject: PassthroughSubject<[BlockId], Never> = .init()
    private(set) var updateElementsPublisher: AnyPublisher<[BlockId], Never> = .empty()
    private var lastSetTextClosure: (() -> Void)?

    // MARK: - Initialization

    init(documentId: String) {
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

    /// Apply last setText action, to ensure text was saved after document was closed
    func applyPendingChanges() {
        self.lastSetTextClosure?()
    }

    // MARK: - Setup subscriptions

    private func setupSubscriptions() {
        self.publicActionsPayloadPublisher.sink { [weak self] (value) in
            self?.process(actionsPayload: value)
        }.store(in: &self.subscriptions)

        _ = self.blockActionHandler.configured(self.publicActionsPayloadPublisher)

        self.listToolbarSubject.sink { [weak self] (value) in
            self?.process(toolbarAction: value)
        }.store(in: &self.subscriptions)

        _ = self.listBlockActionHandler.configured(self.listActionsPayloadPublisher)

        self.blockActionHandler.reactionPublisher.sink { [weak self] (value) in
            self?.process(reaction: value)
        }.store(in: &self.subscriptions)

        self.listBlockActionHandler.reactionPublisher.sink { [weak self] (value) in
            self?.process(reaction: value)
        }.store(in: &self.subscriptions)

        self.$builders.sink { [weak self] value in
            self?.enhanceUserActionsAndPayloads(value)
        }.store(in: &self.subscriptions)
    }

    // TODO: Add caching?
    private func update(builders: [BaseBlockViewModel]) {
        let difference = builders.difference(from: self.builders) {$0.diffable == $1.diffable}
        if !difference.isEmpty, let result = self.builders.applying(difference) {
            self.builders = result
            self.viewInput?.updateData(self.builders)
        }
    }

    private func obtainDocument(documentId: String?) {
        guard let documentId = documentId else { return }
        self.internalState = .loading

        self.blockActionsService.open(contextID: documentId, blockID: documentId)
            .reciveOnMain()
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

    private func remove(buildersWith ids: [BlockId]) {
        let targetIds: Set<BlockId> = .init(ids)
        var indexSet: IndexSet = .init()
        var itemsToDelete: [BaseBlockViewModel] = []

        let startIndex = self.builders.startIndex
        let endIndex = self.builders.endIndex

        var buildersIndex = startIndex

        while buildersIndex != endIndex, targetIds.count != itemsToDelete.count {
            let item = self.builders[buildersIndex]
            if targetIds.contains(item.blockId) {
                indexSet.insert(buildersIndex)
                itemsToDelete.append(item)
            }
            buildersIndex = buildersIndex.advanced(by: 1)
        }
        self.builders.remove(atOffsets: indexSet)
        self.viewInput?.delete(rows: itemsToDelete)
    }

    private func insert(builders: [BaseBlockViewModel], after blockId: BlockId) {
        guard let index = self.builders.firstIndex(where: { $0.blockId == blockId }) else { return }
        let builder = self.builders[index]
        self.builders.insert(contentsOf: builders, at: index + 1)
        self.viewInput?.insert(rows: builders, after: builder)
    }


    private func handleOpenDocument(_ value: ServiceSuccess) {
        // sink publisher
        self.documentViewModel.updatePublisher()
            .reciveOnMain()
            .sink { [weak self] (value) in
                switch value.updates {
                case .general:
                    self?.update(builders: value.models)
                case let .update(update):
                    if let toggledId = update.openedToggleId {
                        self?.insert(builders: value.models, after: toggledId)
                    }
                    if !update.addedIds.isEmpty {
                        self?.update(builders: value.models)
                    }
                    if !update.updatedIds.isEmpty && update.addedIds.isEmpty && update.deletedIds.isEmpty {
                        // During split or merge neighborhood blocks will update automaticaly because of
                        // calculating diff in data source
                        self?.updateDiffableValuesForBlockIds(update.updatedIds)
                        self?.updateElementsSubject.send(update.updatedIds)
                    }
                    if !update.deletedIds.isEmpty {
                        self?.remove(buildersWith: update.deletedIds)
                        let ids = update.deletedIds.reduce(into: [BlockId: BlockContentType]()) { result, blockId in
                            guard let container = self?.documentViewModel.rootActiveModel?.container else { return }
                            result[blockId] = container.get(by: blockId)?.information.content.type
                        }
                        self?.deselect(ids: ids)
                    }
                }
            }.store(in: &self.subscriptions)
        self.documentViewModel.open(value)
        self.configureDetails()
        self.configureInteractions(self.documentViewModel.documentId)
    }
    
    private func updateDiffableValuesForBlockIds(_ ids: [BlockId]) {
        // In case we update just several blocks (for example turn into Paragraph -> Header)
        // we also need to update diffable value for such blocks
        // to reduce updates when we will calculate differencies using diff algorithm
        let updatesSet = Set(ids)
        let updatedViewModels = builders.filter { updatesSet.contains($0.blockId) }
        updatedViewModels.forEach { $0.updateDiffable() }
    }

    private func configureInteractions(_ documentId: BlockId?) {
        guard let documentId = documentId else {
            assertionFailure("configureInteractions(_:). DocumentId is not configured.")
            return
        }
        _ = self.blockActionHandler.configured(documentId: documentId).configured(self)
        _ = self.listBlockActionHandler.configured(documentId: documentId)
    }

    private func configureDetails() {
        let detailsViewModels = self.documentViewModel.detailsViewModels()
        var dictionary: PageDetailsViewModelsDictionary = [:]
        /// TODO:
        /// Refactor when you are ready.
        /// It is tough stuff.
        ///
        if let iconEmoji = detailsViewModels.first(where: {$0 as? PageIconViewModel != nil}) {
            dictionary[.iconEmoji] = iconEmoji
        }
        self.detailsViewModels = dictionary
    }
}

// MARK: - DocumentViewInteraction

extension DocumentEditorViewModel: DocumentViewInteraction {
    func updateBlocks(with ids: [BlockId]) {
        self.updateElementsSubject.send(ids)
    }
}

// MARK: - Reactions

private extension DocumentEditorViewModel {
    func process(reaction: BlockActionsHandlersFacade.Reaction) {
        switch reaction {
        case let .shouldHandleEvent(value):
            let events = value.payload.events
            let actionType = value.actionType

            self.documentViewModel.handle(events: events)

            switch actionType {
            case .deleteBlock, .merge:
                let firstResponderBlockId = self.documentViewModel.userSession?.firstResponder()
                
                if let firstResponderIndex = self.builders.firstIndex(where: { $0.blockId == firstResponderBlockId }) {
                    self.viewInput?.setFocus(at: firstResponderIndex)
                }
            default: break
            }
        default: return
        }
    }

    func process(reaction: ListBlockActionHandler.Reaction) {
        switch reaction {
        case let .shouldHandleEvent(value):
            let events = value.payload.events
            self.documentViewModel.handle(events: events)
        }
    }
}

// MARK: - On Tap Gesture

extension DocumentEditorViewModel {
    func handlingTapIfEmpty() {
        self.blockActionHandler.createEmptyBlock(
            listIsEmpty: self.state == .empty, parentModel: self.documentViewModel.rootActiveModel
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
        guard self.builders.indices.contains(at.row) else {
            assertionFailure("Row doesn't exist")
            return nil
        }
        return self.builders[at.row]
    }

    private func didSelect(atIndex: IndexPath) {
        guard let item = element(at: atIndex) else { return }
        self.set(selected: !self.selected(id: item.blockId),
                 id: item.blockId,
                 type: item.getBlock().blockModel.information.content.type)
    }
}

// MARK: - Process actions

private extension DocumentEditorViewModel {
    func process(actionsPayload: BaseBlockViewModel.ActionsPayload) {
        switch actionsPayload {
        case let .textView(value):
            switch value.action {
            case .textView(.showMultiActionMenuAction(.showMultiActionMenu)):
                self.set(selectionEnabled: true)
            default: return
            }
        // TODO: we need coordinator(router) here that show this view https://app.clickup.com/t/h13ytp
        case let .showCodeLanguageView(languages, completion):
            self.viewInput?.showCodeLanguageView(with: languages, completion: completion)
        case .showStyleMenu:
//            self.publicUserActionSubject.send()
            self.viewInput?.showStyleMenu()
        default: return
        }
    }

    func process(_ value: EditorModule.Selection.ToolbarPresenter.SelectionAction) {
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
            case let .turnInto(payload): self.publicUserActionSubject.send(.toolbars(.turnIntoBlock(.init(output: self.listToolbarSubject, input: payload))))
            case .delete: self.listActionsPayloadSubject.send(.toolbar(.init(model: selectedIds, action: .editBlock(.delete))))
            case .copy: break
            }
        }
    }

    func process(toolbarAction: BlocksViews.Toolbar.UnderlyingAction) {
        let selectedIds = self.list()
        self.listActionsPayloadSubject.send(.toolbar(.init(model: selectedIds, action: toolbarAction)))
    }
}

extension DocumentEditorViewModel {
    enum ActionsPayload {
        typealias ListModel = [BlockId]

        struct Toolbar {
            typealias Model = ListModel
            typealias Action = BlocksViews.Toolbar.UnderlyingAction
            var model: Model
            var action: Action
        }
        
        case toolbar(Toolbar)
    }
}

extension DocumentEditorViewModel {
    func configured(multiSelectionUserActionPublisher: AnyPublisher<EditorModule.Selection.ToolbarPresenter.SelectionAction, Never>) -> Self {
        multiSelectionUserActionPublisher.sink { [weak self] (value) in
            self?.process(value)
        }.store(in: &self.subscriptions)
        return self
    }

    func configured(selectionHandler: EditorModuleSelectionHandlerProtocol?) -> Self {
        self.selectionHandler = selectionHandler
        return self
    }
}

// MARK: - Debug

extension DocumentEditorViewModel: CustomDebugStringConvertible {
    var debugDescription: String {
        "\(String(reflecting: Self.self)) -> \(String(describing: self.documentViewModel.documentId))"
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
    func enhanceUserActionsAndPayloads(_ builders: [BlockViewBuilderProtocol]) {
        let ourViewModels = builders.compactMap({$0 as? BaseBlockViewModel})
        ourViewModels.forEach { (value) in
            _ = value.configured(userActionSubject: self.publicUserActionSubject)
            _ = value.configured(actionsPayloadSubject: self.publicActionsPayloadSubject)
            _ = value.configured(sizeDidChangeSubject: self.publicSizeDidChangeSubject)
        }
    }
    
    func enhanceDetails(_ value: PageDetailsViewModelsDictionary) {
        let ourValues = value.values.compactMap({$0 as? BaseBlockViewModel})
        ourValues.forEach { (value) in
            _ = value.configured(userActionSubject: self.publicUserActionSubject)
            _ = value.configured(actionsPayloadSubject: self.publicActionsPayloadSubject)
        }
    }
}

// MARK: - Public methods for view controller

extension DocumentEditorViewModel {

    /// Block action handler
    func handleAction(_ action: BlockActionHandler.ActionType) {

    }
}
