//
//  CodeBlockViewModel.swift
//  Anytype
//
//  Created by Denis Batvinkin on 23.05.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Combine
import UIKit
import BlocksModels


// MARK: - CodeBlockViewModel

final class CodeBlockViewModel: BaseBlockViewModel {
    private enum Constants {
        static let codeLanguageFieldName = "lang"
    }

    private struct Options {
        var throttlingInterval: DispatchQueue.SchedulerTimeType.Stride = .seconds(1)
    }

    private var serialQueue = DispatchQueue(label: "BlocksViews.Text.Base.SerialQueue")
    private var textOptions: Options = .init()

    private var subscriptions: Set<AnyCancellable> = []
    private var toModelTextSubject: PassthroughSubject<NSAttributedString, Never> = .init()

    weak var codeBlockView: CodeBlockViewInteractable?

    // MARK: Services
    private var service: BlockActionsServiceText = .init()
    private let listService: BlockActionsServiceList = .init()

    // MARK: View state
    @Published private(set) var shouldResignFirstResponder = PassthroughSubject<Void, Never>()
    @Published private(set) var textViewUpdate: TextViewUpdate?
    @Published var focus: BlockFocusPosition?
    @Published var codeLanguage: String? = "Swift"

    // MARK: - Life cycle

    override init(_ block: BlockActiveRecordModelProtocol) {
        super.init(block)
        self.setupSubscribers()

        if let lang = block.blockModel.information.fields[Constants.codeLanguageFieldName]?.stringValue {
            codeLanguage = lang
        }
    }

    // MARK: - Subclassing accessors

    override func makeContentConfiguration() -> UIContentConfiguration {
        var configuration = CodeBlockContentConfiguration(self)
        configuration.viewModel = self
        return configuration
    }

    override func handle(contextualMenuAction: BlocksViews.ContextualMenu.MenuAction.Action) {
        super.handle(contextualMenuAction: contextualMenuAction)
    }
    
    override func makeContextualMenu() -> BlocksViews.ContextualMenu {
        BlocksViews.ContextualMenu(title: "",
                                   children: [.create(action: .general(.addBlockBelow)),
                                              .create(action: .specific(.turnIntoPage)),
                                              .create(action: .general(.delete)),
                                              .create(action: .general(.duplicate))])
    }

    func setCodeLanguage(_ language: String) {
        guard let contextId = block.container?.rootId else { return }

        let blockFields = BlockFields(blockId: blockId, fields: [Constants.codeLanguageFieldName: language])
        listService.setFields(contextID: contextId, blockFields: [blockFields]).sink { _ in } receiveValue: { _ in }.store(in: &subscriptions)
    }
}

// MARK: - TextViewDelegate

extension CodeBlockViewModel: TextViewDelegate {
    func changeFirstResponderState(_ change: TextViewFirstResponderChange) {
        send(actionsPayload: .becomeFirstResponder(block.blockModel))
    }

    func sizeChanged() {
        needsUpdateLayout()
    }
}

// MARK: - Setup

private extension CodeBlockViewModel {

    func setupSubscribers() {
        // Update text view in code block
        block.didChangePublisher().receive(on: serialQueue)
            .map { [weak self] _ -> BlockText? in
                let value = self?.block.blockModel.information

                if let lang = value?.fields[Constants.codeLanguageFieldName]?.stringValue {
                    self?.codeLanguage = lang
                    self?.codeBlockView?.languageDidChange(language: lang)
                }
                switch value?.content {
                case let .text(value): return value
                default: return nil
                }
            }
            .safelyUnwrapOptionals()
            .receiveOnMain()
            .map { textContent -> TextViewUpdate in
                let blockColor = MiddlewareColorConverter.asModel(textContent.color)
                return .payload(.init(attributedString: textContent.attributedText, auxiliary: .init(textAlignment: .left,
                                                                                              blockColor: blockColor)))
            }
            .sink { [weak self] textViewUpdate in
                self?.textViewUpdate = textViewUpdate
            }.store(in: &self.subscriptions)

        // update code block model
        self.toModelTextSubject.receive(on: serialQueue).sink { [weak self] (value) in
            self?.setModelData(attributedText: value)
        }.store(in: &self.subscriptions)
    }
}

// MARK: - Set Focus

extension CodeBlockViewModel {
    func set(focus: BlockFocusPosition?) {
        self.focus = focus
    }
}

// MARK: - Actions Payload Legacy

extension CodeBlockViewModel {
    func send(textViewAction: TextBlockUserInteraction) {
        self.send(actionsPayload: .textView(.init(model: block, action: textViewAction)))
    }
}

// MARK: - Apply to model

private extension CodeBlockViewModel {
    func setModelData(attributedText: NSAttributedString) {
        // Update model.
        self.update { (block) in
            switch block.content {
            case var .text(value):
                guard value.attributedText != attributedText else { return }
                let attributedText: NSAttributedString = .init(attributedString: attributedText)
                value.attributedText = attributedText
                var blockModel = block.blockModel
                blockModel.information.content = .text(value)
            default: return
            }
        }
    }
}

// MARK: - TextViewUserInteractionProtocol

extension CodeBlockViewModel: TextViewUserInteractionProtocol {
    func didReceiveAction(_ action: BlockTextView.UserAction) {
        switch action {
        case .addBlockAction:
            self.send(
                userAction: .addBlock(.init(output: self.toolbarActionSubject))
            )
        case .showStyleMenu:
            self.send(actionsPayload: .showStyleMenu(blockModel: block.blockModel, blockViewModel: self))
        case .showMultiActionMenuAction:
            self.shouldResignFirstResponder.send()
            self.send(actionsPayload: .textView(.init(model: block, action: .textView(action))))
        case .inputAction, .keyboardAction:
            self.send(actionsPayload: .textView(.init(model: block, action: .textView(action))))
        case .changeCaretPosition:
            typealias TextBlockInteraction = ActionsPayload.TextBlocksViewsUserInteraction
            self.send(actionsPayload: .textView(TextBlockInteraction(model: block, action: .textView(action))))
        }
    }
}

// MARK: - Debug

extension CodeBlockViewModel: CustomDebugStringConvertible {
    var debugDescription: String {
        guard case let .text(text) = information.content else {
            return "id: \(blockId) text block with wrong content type!!! See BlockInformation"
        }
        return "id: \(blockId)\ntext: \(text.attributedText.string.prefix(10))...\ntype: \(text.contentType)"
    }
}
