//
//  BlocksViews+Supplement+TreeTextBlocksUserInteractor+EventsTranslator.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 29.05.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine
import os

private extension Logging.Categories {
    static let treeTextBlocksUserInteractorEventsTranslator: Self = "treeTextBlocksUserInteractorEventsTranslator"
}

/// Backward compatibility events translator
/// It translates new events to old TreeTextBlocksUserInteractor.
extension BlocksViews.Supplement.TreeTextBlocksUserInteractor {
    class EventsTranslator {
        private weak var treeTextBlocksUserInteractor: TextBlocksViewsUserInteractionProtocol?
        private struct Tuple {
            var action: TextBlocksViews.UserInteraction?
            var model: BlockModels.Block.RealBlock?
        }
        
        private var subscription: AnyCancellable?
        private var publisher: AnyPublisher<BlocksViews.Base.ViewModel.ActionsPayload, Never> = .empty()
        private func setupSubscribers() {
            self.subscription?.cancel()
            self.subscription = nil
            self.subscription = self.publisher.sink(receiveValue: { [weak self] (value) in
                self?.handle(action: value)
            })
        }
        
        private func convert(toolbarAction: BlocksViews.Base.ViewModel.ActionsPayload) -> Tuple? {
            switch toolbarAction {
            case let .toolbar(action): return .init(action: .textView(Converter.convert(action.action)), model: action.model)
            case let .textView(action): return .init(action: action.action, model: action.model)
            }
        }
        
        // MARK: Handling
        private func handle(action: BlocksViews.Base.ViewModel.ActionsPayload) {
            guard let tuple = self.convert(toolbarAction: action), let model = tuple.model, let action = tuple.action else { return }
            self.treeTextBlocksUserInteractor?.didReceiveAction(block: model, id: model.indexPath, generalAction: action)
        }
        
        // MARK: Configuration
        func configured(_ interactor: TextBlocksViewsUserInteractionProtocol?) -> Self {
            self.treeTextBlocksUserInteractor = interactor
            return self
        }
        
        func configured(_ stream: AnyPublisher<BlocksViews.Base.ViewModel.ActionsPayload, Never>) -> Self {
            self.publisher = stream
            self.setupSubscribers()
            return self
        }
    }
}

// TODO: Delete it when you remove `TextView.UserAction` or change actions processing.
private extension BlocksViews.Supplement.TreeTextBlocksUserInteractor.EventsTranslator {
    /// Backward compatibilty actions converter.
    /// It converts new toolbar actions to old `TextView.UserAction`.
    enum Converter {
        private static func convert(_ value: BlocksViews.Toolbar.UnderlyingAction.BlockType) -> TextView.UserAction.BlockAction.BlockType {
            let logger = Logging.createLogger(category: .treeTextBlocksUserInteractorEventsTranslator)
            os_log(.debug, log: logger, "Do not use this method later. It is deprecated. Remove it when you are ready.")
            switch value {
            case let .text(value):
                switch value {
                case .text: return .text(.text)
                case .h1: return .text(.h1)
                case .h2: return .text(.h2)
                case .h3: return .text(.h3)
                case .highlighted: return .text(.highlighted)
                }
            case let .list(value):
                switch value {
                case .bulleted: return .list(.bulleted)
                case .checkbox: return .list(.checkbox)
                case .numbered: return .list(.numbered)
                case .toggle: return .list(.toggle)
                }
            case let .page(value):
                switch value {
                case .page: return .tool(.page)
                case .existingPage: return .tool(.existingTool)
                }
            case let .media(value):
                switch value {
                case .file: return .media(.file)
                case .picture: return .media(.picture)
                case .video: return .media(.video)
                case .bookmark: return .media(.bookmark)
                case .code: return .media(.code)
                }
            case let .tool(value):
                switch value {
                case .contact: return .tool(.contact)
                case .database: return .tool(.database)
                case .set: return .tool(.set)
                case .task: return .tool(.task)
                }
            case let .other(value):
                switch value {
                case .divider: return .other(.divider)
                case .dots: return .other(.divider)
                }
            }
        }
        /// Convert new tooblar actions to old text view user action for backward compatibility.
        /// - Parameter action: new toolbar action
        /// - Returns: old text view user action.
        static func convert(_ action: BlocksViews.Toolbar.UnderlyingAction) -> TextView.UserAction {
            switch action {
            case let .addBlock(value): return .blockAction(.addBlock(convert(value)))
            case let .turnIntoBlock(value): return .blockAction(.turnIntoBlock(convert(value)))
            case let .changeColor(value):
                switch value {
                case let .textColor(value): return .blockAction(.changeColor(.textColor(value)))
                case let .backgroundColor(value): return .blockAction(.changeColor(.backgroundColor(value)))
                }
            case let .editBlock(value):
                switch value {
                case .delete: return .blockAction(.editBlock(.delete))
                case .duplicate: return .blockAction(.editBlock(.duplicate))
                }
            }
        }
    }
}
