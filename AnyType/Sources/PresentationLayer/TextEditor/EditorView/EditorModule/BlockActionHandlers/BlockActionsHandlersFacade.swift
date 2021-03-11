//
//  BlockActionsHandlersFacade.swift
//  AnyType
//
//  Created by Denis Batvinkin on 16.02.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import Combine
import BlocksModels
import os


private extension Logging.Categories {
    static let textEditorUserInteractorHandler: Self = "TextEditor.UserInteractionHandler"
}

final class BlockActionsHandlersFacade {
    typealias ActionsPayload = BlocksViews.New.Base.ViewModel.ActionsPayload
    // TODO: remove when possible
    typealias ActionsPayloadTextViewTextView = ActionsPayload.TextBlocksViewsUserInteraction.Action.TextViewUserAction
    typealias ActionsPayloadToolbar = ActionsPayload.Toolbar.Action

    /// Action type that happens with block.
    ///
    /// View that contain blocks can use this actions type to understant what happened with blocks.
    /// For example, when block deleted we need first set focus to previous block  before model will be updated  to prevent hide keyboard.
    enum ActionType {
        /// Block deleted
        case deleteBlock
        /// Block merged (when we delete block that has text after cursor )
        case merge
    }

    enum Reaction {
        typealias Id = TopLevel.AliasesMap.BlockId

        struct ShouldOpenPage {
            struct Payload {
                var blockId: Id
            }

            var payload: Payload
        }

        struct ShouldHandleEvent {
            struct Payload {
                var events: EventListening.PackOfEvents
            }

            var actionType: ActionType?
            var payload: Payload
        }

        case shouldOpenPage(ShouldOpenPage)
        case shouldHandleEvent(ShouldHandleEvent)
    }

    private var subscription: AnyCancellable?
    private let service: BlockActionService = .init(documentId: "")
    private var documentId: String = ""
    private var indexWalker: LinearIndexWalker?
    
    private lazy var textBlockActionHandler: TextBlockActionHandler = .init(service: service, indexWalker: indexWalker)
    private lazy var toolbarBlockActionHandler: ToolbarBlockActionHandler = .init(service: service, indexWalker: indexWalker)
    private lazy var marksPaneBlockActionHandler: MarksPaneBlockActionHandler = .init(service: service, contextId: self.documentId, subject: reactionSubject)
    private lazy var buttonBlockActionHandler: ButtonBlockActionHandler = .init(service: service)
    private lazy var userActionHandler: UserActionHandler = .init(service: service)

    private let reactionSubject: PassthroughSubject<Reaction?, Never> = .init()
    private(set) var reactionPublisher: AnyPublisher<Reaction, Never> = .empty()

    init() {
        self.setup()
    }

    func setup() {
        self.reactionPublisher = self.reactionSubject.safelyUnwrapOptionals().eraseToAnyPublisher()
        // config block action service with completion that send value to subscriber (EditorModule.Document.ViewController.ViewModel)
        _ = self.service.configured { [weak self] (actionType, value) in
            self?.reactionSubject.send(.shouldHandleEvent(.init(actionType: actionType, payload: .init(events: value))))
        }
    }

    /// Attaches subscriber to base blocks views (BlocksViews.New.Base) publisher
    /// - Parameter publisher: Publisher that send action from block view to this handler
    /// - Returns: self
    func configured(_ publisher: AnyPublisher<ActionsPayload, Never>) -> Self {
        self.subscription = publisher.sink { [weak self] (value) in
            self?.didReceiveAction(action: value)
        }
        return self
    }

    func configured(documentId: String) -> Self {
        self.documentId = documentId
        _ = self.service.configured(documentId: documentId)
        return self
    }

    func configured(_ model: EditorModule.Document.ViewController.ViewModel) -> Self {
        self.indexWalker = .init(DocumentModelListProvider.init(model: model))
        return self
    }

    func didReceiveAction(action: ActionsPayload) {
        switch action {
        case let .toolbar(value): self.toolbarBlockActionHandler.handlingToolbarAction(value.model, value.action)
        case let .marksPane(value): self.marksPaneBlockActionHandler.handlingMarksPaneAction(value.model, value.action)
        case let .textView(value):
            switch value.action {
            case let .textView(action): textBlockActionHandler.handlingTextViewAction(value.model, action)
            case let .buttonView(action):
                self.buttonBlockActionHandler.handlingButtonViewAction(value.model, action)
            }
        case let .userAction(value): self.userActionHandler.handlingUserAction(value.model, value.action)
        }
    }
}

// MARK: TODO - Move to enum or wrap in another protocol
extension BlockActionsHandlersFacade {
    func createEmptyBlock(listIsEmpty: Bool, parentModel: BlockActiveRecordModelProtocol?) {
        if listIsEmpty {
            if let defaultBlock = BlockBuilder.createDefaultInformation() {
                self.service.addChild(childBlock: defaultBlock, parentBlockId: self.documentId)
            }
        }
        else {
            // Unknown for now.
            // Check that previous ( last block ) is not nil.
            // We must provide a smartblock of page to solve it.
            //
            guard let parentModel = parentModel else {
                // We don't have parentModel, so, we can't proceed.
                let logger = Logging.createLogger(category: .textEditorUserInteractorHandler)
                os_log(.debug, log: logger, "createEmptyBlock.listIsEmpty. We don't have parent model.")
                return
            }
            guard let lastChildId = parentModel.childrenIds().last else {
                // We don't have children, let's do nothing.
                let logger = Logging.createLogger(category: .textEditorUserInteractorHandler)
                os_log(.debug, log: logger, "createEmptyBlock.listIsEmpty. Children are empty.")
                return
            }
            guard let lastChild = parentModel.container?.choose(by: lastChildId) else {
                // No child - nothing to do.
                let logger = Logging.createLogger(category: .textEditorUserInteractorHandler)
                os_log(.debug, log: logger, "createEmptyBlock.listIsEmpty. Last child doesn't exist.")
                return
            }

            switch lastChild.blockModel.information.content {
            case let .text(value) where value.attributedText.length == 0:
                let logger = Logging.createLogger(category: .textEditorUserInteractorHandler)
                os_log(.debug, log: logger, "createEmptyBlock.listIsEmpty. Last block is text and it is empty. Skipping..")
                return
            default:
                if let defaultBlock = BlockBuilder.createDefaultInformation() {
                    self.service.addChild(childBlock: defaultBlock, parentBlockId: self.documentId)
                }
            }
        }
    }
}

// MARK: - LinearIndexWalker

final class LinearIndexWalker {
    typealias Model = BlockActiveRecordModelProtocol

    private var models: [Model] = []
    var listModelsProvider: UserInteractionHandlerListModelsProvider

    init(_ listModelsProvider: UserInteractionHandlerListModelsProvider) {
        self.listModelsProvider = listModelsProvider
    }

    private func configured(models: [Model]) {
        self.models = models
    }

    private func configured(listModelsProvider: UserInteractionHandlerListModelsProvider) {
        self.listModelsProvider = listModelsProvider
    }

    func renew() {
        self.configured(models: self.listModelsProvider.getModels)
    }
}

// MARK: Search
extension LinearIndexWalker {
    func model(beforeModel model: Model, includeParent: Bool, onlyFocused: Bool = true) -> Model? {
        /// Do we actually need parent?
        guard let modelIndex = self.models.firstIndex(where: { $0.blockModel.information.id == model.blockModel.information.id }) else { return nil }

        /// Iterate back
        var index = self.models.index(before: modelIndex)
        let startIndex = self.models.startIndex

        /// TODO:
        /// Look at documentation how we should handle different blocks types.
        while index >= startIndex {
            let object = self.models[index]
            switch object.blockModel.information.content {
            case .text: return object
            case let .layout(value) where value.style == .div: index = self.models.index(before: index)
            default: return nil
            }
        }

        return nil
    }
}

// MARK: - DocumentModelListProvider

// MARK: ListModelsProvider
protocol UserInteractionHandlerListModelsProvider {
    var getModels: [BlockActiveRecordModelProtocol] {get}
}

struct DocumentModelListProvider: UserInteractionHandlerListModelsProvider {
    private typealias ViewModel = EditorModule.Document.ViewController.ViewModel
    private weak var model: ViewModel?
    private var _models: [BlockActiveRecordModelProtocol] = [] // Do we need cache?
    init(model: EditorModule.Document.ViewController.ViewModel) {
        self.model = model
    }
    var getModels: [BlockActiveRecordModelProtocol] {
        self.model?.builders.compactMap({($0 as! ViewModel.BlocksViewsNamespace.Base.ViewModel).getBlock()}) ?? []
    }
}

// MARK: - BlockBuilder

/// This class should be moved to Middleware.
/// We don't care about business logic on THIS level.
struct BlockBuilder {
    typealias BlockId = TopLevel.AliasesMap.BlockId
    typealias Content = TopLevel.AliasesMap.BlockContent
    typealias Information = BlockInformationModelProtocol

    typealias Builder = TopLevel.Builder

    typealias KeyboardAction = BlockActionsHandlersFacade.ActionsPayloadTextViewTextView.KeyboardAction
    typealias ToolbarAction = BlockActionsHandlersFacade.ActionsPayloadToolbar

    static func newBlockId() -> BlockId { "" }

    static func createInformation(block: BlockActiveRecordModelProtocol, action: KeyboardAction, textPayload: String) -> Information? {
        switch block.blockModel.information.content {
        case .text:
            return self.createContentType(block: block, action: action, textPayload: textPayload).flatMap({(newBlockId(), $0)}).map(Builder.blockBuilder.informationBuilder.build)
        default: return nil
        }
    }

    static func createInformation(block: BlockActiveRecordModelProtocol, action: ToolbarAction, textPayload: String = "") -> Information? {
        switch action {
        case .addBlock: return self.createContentType(block: block, action: action, textPayload: textPayload).flatMap({(newBlockId(), $0)}).map(Builder.blockBuilder.informationBuilder.build)
        default: return nil
        }
    }

    static func createDefaultInformation(block: BlockActiveRecordModelProtocol? = nil) -> Information? {
        guard let block = block else {
            return Builder.blockBuilder.informationBuilder.build(id: newBlockId(), content: .text(.empty()))
        }
        switch block.blockModel.information.content {
        case let .text(value):
            switch value.contentType {
            case .toggle: return Builder.blockBuilder.informationBuilder.build(id: newBlockId(), content: .text(.empty()))
            default: return nil
            }
        case .smartblock: return Builder.blockBuilder.informationBuilder.build(id: newBlockId(), content: .text(.empty()))
        default: return nil
        }
    }

    static func createContentType(block: BlockActiveRecordModelProtocol, action: KeyboardAction, textPayload: String) -> Content? {
        switch block.blockModel.information.content {
        case let .text(blockType):
            switch blockType.contentType {
            case .bulleted where blockType.attributedText.string != "": return .text(.init(contentType: .bulleted))
            case .checkbox where blockType.attributedText.string != "": return .text(.init(contentType: .checkbox))
            case .numbered where blockType.attributedText.string != "": return .text(.init(contentType: .numbered))
            case .toggle where blockType.attributedText.string != "": return .text(.init(contentType: .toggle))
            default: return .text(.init(contentType: .text))
            }
        default: return nil
        }
    }

    static func createContentType(block: BlockActiveRecordModelProtocol, action: ToolbarAction, textPayload: String = "") -> Content? {
        switch action {
        case let .addBlock(blockType):
            switch blockType {
            case let .text(value):
                switch value {
                case .text: return .text(.init(contentType: .text))
                case .h1: return .text(.init(contentType: .header))
                case .h2: return .text(.init(contentType: .header2))
                case .h3: return .text(.init(contentType: .header3))
                case .highlighted: return .text(.init(contentType: .quote))
                }
            case let .list(value):
                switch value {
                case .bulleted: return .text(.init(contentType: .bulleted))
                case .checkbox: return .text(.init(contentType: .checkbox))
                case .numbered: return .text(.init(contentType: .numbered))
                case .toggle: return .text(.init(contentType: .toggle))
                }
            case let .objects(mediaType):
                switch mediaType {
                case .page: return .link(.init(style: .page))
                case .picture: return .file(.init(contentType: .image))
                case .bookmark: return .bookmark(.empty())
                case .file: return .file(.init(contentType: .file))
                case .video: return .file(.init(contentType: .video))
                case .linkToObject: return nil
                }
            case let .other(value):
                switch value {
                case .lineDivider: return .divider(.init(style: .line))
                case .dotsDivider: return .divider(.init(style: .dots))
                case .code: return nil
                }
            default: return nil
            }
        default: return nil
        }
    }
}
