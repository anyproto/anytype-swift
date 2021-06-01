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

    weak var textView: (TextViewUpdatable & TextViewManagingFocus)?
    weak var codeBlockView: CodeBlockViewInteractable?

    // MARK: Services
    private var service: BlockActionsServiceText = .init()
    private let listService: BlockActionsServiceList = .init()

    // MARK: View states
    private(set) var codeLanguage: String? = "Swift"

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
        // After we show contextual menu on UITextView (which is first responder)
        // displaying keyboard on such UITextView becomes impossible (only caret show)
        // it is possible to show it only by changing first responder with other UITextView
        let focusPosition = textView?.obtainFocusPosition()
        textView?.shouldResignFirstResponder()
        super.handle(contextualMenuAction: contextualMenuAction)

        if !focusPosition.isNil {
            let focus = TextViewFocus(position: focusPosition)
            textView?.setFocus(focus)
        }
    }

    func setCodeLanguage(_ language: String) {
        guard let contextId = getBlock().container?.rootId else { return }

        let blockFields = BlockFields(blockId: blockId, fields: [Constants.codeLanguageFieldName: language])
        listService.setFields.action(contextID: contextId, blockFields: [blockFields]).sink { _ in } receiveValue: { _ in }.store(in: &subscriptions)
    }
}

// MARK: - TextViewDelegate

extension CodeBlockViewModel: TextViewDelegate {
    func changeFirstResponderState(_ change: TextViewFirstResponderChange) {
        send(actionsPayload: .becomeFirstResponder(getBlock().blockModel))
    }

    func sizeChanged() {
        needsUpdateLayout()
    }
}

// MARK: - Setup

private extension CodeBlockViewModel {

    func setupSubscribers() {
        // Update text view in code block
        self.getBlock().didChangePublisher().receive(on: serialQueue)
            .map { [weak self] _ -> BlockContent.Text? in
                let value = self?.getBlock().blockModel.information

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
                let blockColor = MiddlewareModelsModule.Parsers.Text.Color.Converter.asModel(textContent.color)
                return .payload(.init(attributedString: textContent.attributedText, auxiliary: .init(textAlignment: .left,
                                                                                              blockColor: blockColor)))
            }
            .sink { [weak self] (value) in
                self?.textView?.apply(update: value)
            }.store(in: &self.subscriptions)

        // update code block model
        self.toModelTextSubject.receive(on: serialQueue).sink { [weak self] (value) in
            self?.setModelData(attributedText: value)
        }.store(in: &self.subscriptions)
    }
}

// MARK: - Set Focus

extension CodeBlockViewModel {
    func set(focus: TextViewFocus?) {
        textView?.setFocus(focus)
    }

    func focusPosition() -> BlockFocusPosition? {
        textView?.obtainFocusPosition()
    }
}

// MARK: - Actions Payload Legacy

extension CodeBlockViewModel {
    func send(textViewAction: TextBlockUserInteraction) {
        self.send(actionsPayload: .textView(.init(model: self.getBlock(), action: textViewAction)))
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
        case let .addBlockAction(value):
            switch value {
            case .addBlock:
                self.send(userAction: .toolbars(.addBlock(.init(output: self.toolbarActionSubject))))
            }
        case .showStyleMenu:
            self.send(actionsPayload: .showStyleMenu(blockModel: self.getBlock().blockModel, blockViewModel: self))
        case .showMultiActionMenuAction(.showMultiActionMenu):
            self.textView?.shouldResignFirstResponder()
            self.send(actionsPayload: .textView(.init(model: self.getBlock(), action: .textView(action))))
        case .inputAction, .keyboardAction:
            self.send(actionsPayload: .textView(.init(model: self.getBlock(), action: .textView(action))))
        case .changeCaretPosition:
            typealias TextBlockInteraction = BaseBlockViewModel.ActionsPayload.TextBlocksViewsUserInteraction
            self.send(actionsPayload: .textView(TextBlockInteraction(model: getBlock(), action: .textView(action))))
        }
    }
}

// MARK: - Debug

extension CodeBlockViewModel: CustomDebugStringConvertible {
    var debugDescription: String {
        guard case let .text(text) = information.content else {
            return "id: \(blockId) text block with wrong content type!!! See BlockInformation.InformationModel"
        }
        return "id: \(blockId)\ntext: \(text.attributedText.string.prefix(10))...\ntype: \(text.contentType)"
    }
}
