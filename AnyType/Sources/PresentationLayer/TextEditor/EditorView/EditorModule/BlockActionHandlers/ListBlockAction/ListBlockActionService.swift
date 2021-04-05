//
//  ListBlockActionService.swift
//  AnyType
//
//  Created by Denis Batvinkin on 17.02.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import BlocksModels
import Combine
import os

private extension Logging.Categories {
    static let textEditorListUserInteractorHandler: Self = "TextEditor.ListUserInteractionHandler"
}

final class ListBlockActionService {
    typealias ListIds = [BlockId]

    private var documentId: String

    private var subscriptions: [AnyCancellable] = []
    private let pageService: SmartBlockActionsService = .init()
    private let listService: BlockActionsServiceList = .init()

    private var didReceiveEvent: (EventListening.PackOfEvents) -> () = { _ in }

    init(documentId: String) {
        self.documentId = documentId
    }

    func configured(documentId: String) -> Self {
        self.documentId = documentId
        return self
    }

    func configured(didReceiveEvent: @escaping (EventListening.PackOfEvents) -> ()) -> Self {
        self.didReceiveEvent = didReceiveEvent
        return self
    }
}

// MARK: - Delete

extension ListBlockActionService {
    func delete(_ blocks: ListIds) {
        // Shit Swift
        let blocksIds = blocks
        // TODO: Add Delete List
        self.listService.delete.action(contextID: self.documentId, blocksIds: blocksIds).receive(on: RunLoop.main).sink(receiveCompletion: { (value) in
            switch value {
            case .finished: return
            case let .failure(error):
                let logger = Logging.createLogger(category: .textEditorListUserInteractorHandler)
                os_log(.error, log: logger, "blocksActions.service.delete without payload got error: %@", "\(error)")
            }
        }, receiveValue: { [weak self] value in
            self?.didReceiveEvent(.init(contextId: value.contextID, events: value.messages))
        }).store(in: &self.subscriptions)
    }
}

// MARK: - Turn Into

/// TODO: Add Div and ConvertChildrenToPages
extension ListBlockActionService {
    typealias BlockContent = TopLevel.BlockContent

    func turnInto(blocks: ListIds, type: BlockContent) {
        switch type {
        case .text: self.setTextStyle(blocks: blocks, type: type)
        case .smartblock: self.setPageStyle(blocks: blocks, type: type)
        case .divider: break
        default: return
        }
    }

    private func setPageStyle(blocks: ListIds, type: BlockContent) {

        guard case .smartblock = type else {
            let logger = Logging.createLogger(category: .textEditorListUserInteractorHandler)
            os_log(.error, log: logger, "Set Page style cannot convert type: %@", "\(String(describing: type))")
            return
        }

        let blocksIds = blocks

        self.pageService.convertChildrenToPages(contextID: self.documentId, blocksIds: blocksIds).sink(receiveCompletion: { (value) in
            switch value {
            case .finished: return
            case let .failure(error):
                let logger = Logging.createLogger(category: .textEditorListUserInteractorHandler)
                os_log(.error, log: logger, "blocksActions.service.turnInto.convertChildrenToPages got error: %@", "\(error)")
            }
        }, receiveValue: { _ in }).store(in: &self.subscriptions)
    }

    private func setTextStyle(blocks: ListIds, type: BlockContent) {
        let blocksIds = blocks

        guard case let .text(text) = type else {
            let logger = Logging.createLogger(category: .textEditorListUserInteractorHandler)
            os_log(.error, log: logger, "Set Text style content is not text style: %@", "\(String(describing: type))")
            return
        }

        self.listService.setTextStyle.action(contextID: self.documentId, blockIds: blocksIds, style: text.contentType).receive(on: RunLoop.main).sink(receiveCompletion: { (value) in
            switch value {
            case .finished: return
            case let .failure(error):
                let logger = Logging.createLogger(category: .textEditorListUserInteractorHandler)
                os_log(.error, log: logger, "blocksActions.service.turnInto.setTextStyle with payload got error: %@", "\(error)")
            }
        }) { [weak self] (value) in
            self?.didReceiveEvent(.init(contextId: value.contextID, events: value.messages))
        }.store(in: &self.subscriptions)
    }
}
