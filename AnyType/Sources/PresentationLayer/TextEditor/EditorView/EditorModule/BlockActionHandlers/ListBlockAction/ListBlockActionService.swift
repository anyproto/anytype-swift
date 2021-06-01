import BlocksModels
import Combine
import os


final class ListBlockActionService {
    typealias ListIds = [BlockId]

    private var documentId: String

    private var subscriptions: [AnyCancellable] = []
    private let pageService: ObjectActionsService = .init()
    private let listService: BlockActionsServiceList = .init()

    private var didReceiveEvent: (PackOfEvents) -> () = { _ in }

    init(documentId: String) {
        self.documentId = documentId
    }

    func configured(documentId: String) -> Self {
        self.documentId = documentId
        return self
    }

    func configured(didReceiveEvent: @escaping (PackOfEvents) -> ()) -> Self {
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
        self.listService.delete(contextID: self.documentId, blocksIds: blocksIds).receiveOnMain()
            .sinkWithDefaultCompletion("blocksActions.service.delete without payload") { [weak self] value in
                self?.didReceiveEvent(.init(contextId: value.contextID, events: value.messages))
            }.store(in: &self.subscriptions)
    }
}

// MARK: - Turn Into

/// TODO: Add Div and ConvertChildrenToPages
extension ListBlockActionService {
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
            assertionFailure("Set Page style cannot convert type: \(type)")
            return
        }

        let blocksIds = blocks
        let objectType = ""

        self.pageService.convertChildrenToPages(contextID: self.documentId, blocksIds: blocksIds, objectType: objectType)
            .sinkWithDefaultCompletion("blocksActions.service.turnInto.convertChildrenToPages") { _ in }
            .store(in: &self.subscriptions)
    }

    private func setTextStyle(blocks: ListIds, type: BlockContent) {
        let blocksIds = blocks

        guard case let .text(text) = type else {
            assertionFailure("Set Text style content is not text style: \(type)")
            return
        }

        self.listService.setTextStyle(contextID: self.documentId, blockIds: blocksIds, style: text.contentType)
            .receiveOnMain()
            .sinkWithDefaultCompletion("blocksActions.service.turnInto.setTextStyle with payload") { [weak self] (value) in
                self?.didReceiveEvent(.init(contextId: value.contextID, events: value.messages))
        }.store(in: &self.subscriptions)
    }
}
