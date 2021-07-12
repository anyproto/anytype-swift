import Combine
import BlocksModels
import os
import UIKit

extension LoggerCategory {
    static let blockActionService: Self = "blockActionService"
}

final class BlockActionService: BlockActionServiceProtocol {
    private var documentId: BlockId

    private var subscriptions: [AnyCancellable] = []
    private let singleService = ServiceLocator.shared.blockActionsServiceSingle()
    private let pageService = ObjectActionsService()
    private let textService = BlockActionsServiceText()
    private let listService = BlockActionsServiceList()
    private let bookmarkService = BlockActionsServiceBookmark()
    private let fileService = BlockActionsServiceFile()

    private var didReceiveEvent: (PackOfEvents) -> () = { _  in }

    init(documentId: String) {
        self.documentId = documentId
    }
    
    /// Method to handle our events from outside of action service
    ///
    /// - Parameters:
    ///   - events: Event to handle
    func receivelocalEvents(_ events: [LocalEvent]) {
        self.didReceiveEvent(PackOfEvents(contextId: documentId, events: [], localEvents: events))
    }

    func configured(documentId: String) -> Self {
        self.documentId = documentId
        return self
    }

    func configured(didReceiveEvent: @escaping (PackOfEvents) -> ()) {
        self.didReceiveEvent = didReceiveEvent
    }

    // MARK: Actions/Add

    func addChild(info: BlockInformation, parentBlockId: BlockId) {
        add(info: info, targetBlockId: parentBlockId, position: .inner, shouldSetFocusOnUpdate: true)
    }

    func add(info: BlockInformation, targetBlockId: BlockId, position: BlockPosition, shouldSetFocusOnUpdate: Bool) {
        singleService.add(contextID: self.documentId, targetID: targetBlockId, info: info, position: position)
            .receiveOnMain()
            .sinkWithDefaultCompletion("blocksActions.service.add") { [weak self] (value) in
                let value = shouldSetFocusOnUpdate ? value.addEvent : value.defaultEvent
                self?.didReceiveEvent(value)
            }.store(in: &self.subscriptions)
    }

    func split(
        info: BlockInformation,
        oldText: String,
        newBlockContentType: BlockText.ContentType,
        shouldSetFocusOnUpdate: Bool
    ) {
        let blockId = info.id
        // We are using old text as a cursor position.
        let position = oldText.count

        let content = info.content
        guard case let .text(type) = content else {
            assertionFailure("We have unsupported content type: \(content)")
            return
        }

        let range = NSRange(location: position, length: 0)

        let documentId = self.documentId

        self.textService.setText(contextID: documentId, blockID: blockId, attributedString: type.attributedText).flatMap({ [weak self] value -> AnyPublisher<ServiceSuccess, Error> in
            return self?.textService.split(
                contextID: documentId,
                blockID: blockId,
                range: range,
                style: newBlockContentType) ?? .empty()
        }).sinkWithDefaultCompletion("blocksActions.service.setTextAndSplit") { [weak self] serviceSuccess in
            var events = shouldSetFocusOnUpdate ? serviceSuccess.splitEvent : serviceSuccess.defaultEvent
            events.localEvents = [.setTextMerge(blockId: blockId)] + events.localEvents
            self?.didReceiveEvent(events)
        }.store(in: &self.subscriptions)
    }

    func duplicate(blockId: BlockId) {
        let blockIds: [String] = [blockId]
        let position: BlockPosition = .bottom
        
        singleService.duplicate(
            contextID: documentId,
            targetID: blockId,
            blockIds: blockIds,
            position: position
        ).sinkWithDefaultCompletion("blocksActions.service.duplicate") { [weak self] (value) in
            self?.didReceiveEvent(PackOfEvents(contextId: value.contextID, events: value.messages))
        }.store(in: &self.subscriptions)
    }

    func createPage(position: BlockPosition = .bottom) {
        pageService.createPage(
            contextID: self.documentId,
            targetID: "",
            details: [.name: DetailsEntry(value: "")],
            position: position,
            templateID: ""
        )
        .receiveOnMain()
        .sinkWithDefaultCompletion("blocksActions.service.createPage with payload") { [weak self] (value) in
            self?.didReceiveEvent(PackOfEvents(contextId: value.contextID, events: value.messages))
        }.store(in: &self.subscriptions)
    }

    func turnInto(blockId: BlockId, type: BlockContent, shouldSetFocusOnUpdate: Bool) {
        switch type {
        case .text: setTextStyle(blockId: blockId, type: type, shouldFocus: shouldSetFocusOnUpdate)
        case .smartblock: setPageStyle(blockId: blockId, type: type)
        case .divider: setDividerStyle(blockId: blockId, type: type)
        default: return
        }
    }
    
    func checked(blockId: BlockId, newValue: Bool) {
        self.textService.checked(contextId: documentId, blockId: blockId, newValue: newValue)
            .receiveOnMain()
            .sinkWithDefaultCompletion("textService.checked with payload") { [weak self] value in
                self?.didReceiveEvent(PackOfEvents(contextId: value.contextID, events: value.messages))
            }.store(in: &self.subscriptions)
    }
    
    func delete(blockId: BlockId, completion: @escaping Conversion) {
        let blockIds = [blockId]
        singleService.delete(contextID: self.documentId, blockIds: blockIds)
            .receiveOnMain()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: return
                case let .failure(error):
                    // It occurs if you press delete at the beginning of title block
                    Logger.create(.blockActionService).debug(
                        "blocksActions.service.delete without payload got error: \(error.localizedDescription)"
                    )
                }
            }) { [weak self] value in
                let value = completion(value)
                self?.didReceiveEvent(value)
            }.store(in: &self.subscriptions)
    }
    
    func setFields(contextID: BlockId, blockFields: [BlockFields]) {
        listService.setFields(contextID: contextID, blockFields: blockFields)
            .sinkWithDefaultCompletion("listService.setFields") { [weak self] serviceSuccess in
                self?.didReceiveEvent(serviceSuccess.defaultEvent)
            }.store(in: &self.subscriptions)
    }
}

private extension BlockActionService {
    func split(block: BlockInformation, oldText: String, _ completion: @escaping Conversion) {
        // TODO: You should update parameter `oldText`. It shouldn't be a plain `String`. It should be either `Int32` to reflect cursor position or it should be `NSAttributedString`

        // We are using old text as a cursor position.
        let blockId = block.id
        let position = oldText.count

        let content = block.content
        guard case let .text(type) = content else {
            assertionFailure("We have unsupported content type: \(content)")
            return
        }

        let range = NSRange(location: position, length: 0)

        self.textService.split(contextID: self.documentId, blockID: blockId, range: range, style: type.contentType)
            .receiveOnMain()
            .sinkWithDefaultCompletion("blocksActions.service.split without payload") { [weak self] (value) in
                let value = completion(value)
                self?.didReceiveEvent(value)
            }.store(in: &self.subscriptions)
    }

    func setDividerStyle(blockId: BlockId, type: BlockContent) {
        guard case let .divider(value) = type else {
            assertionFailure("SetDividerStyle content is not divider: \(type)")
            return
        }

        let blocksIds = [blockId]

        listService.setDivStyle(contextID: self.documentId, blockIds: blocksIds, style: value.style)
            .sinkWithDefaultCompletion("blocksActions.service.turnInto.setDivStyle") { [weak self] serviceSuccess in
                self?.didReceiveEvent(serviceSuccess.defaultEvent)
        }.store(in: &self.subscriptions)
    }

    func setPageStyle(blockId: BlockId, type: BlockContent) {
        let objectType = ""

        guard case .smartblock = type else {
            assertionFailure("Set Page style cannot convert type: \(type)")
            return
        }

        let blocksIds = [blockId]

        self.pageService.convertChildrenToPages(contextID: self.documentId, blocksIds: blocksIds, objectType: objectType)
            .sinkWithDefaultCompletion("blocksActions.service.turnInto.convertChildrenToPages") { _ in }
        .store(in: &self.subscriptions)
    }

    func setTextStyle(blockId: BlockId, type: BlockContent, shouldFocus: Bool) {
        guard case let .text(text) = type else {
            assertionFailure("Set Text style content is not text style: \(type)")
            return
        }

        self.textService.setStyle(contextID: self.documentId, blockID: blockId, style: text.contentType)
            .receiveOnMain()
            .sinkWithDefaultCompletion("blocksActions.service.turnInto.setTextStyle") { [weak self] serviceSuccess in
                let events = shouldFocus ? serviceSuccess.turnIntoTextEvent : serviceSuccess.defaultEvent
                self?.didReceiveEvent(events)
            }.store(in: &self.subscriptions)
    }
}

// MARK: - Delete

extension BlockActionService {
    func merge(firstBlockId: BlockId, secondBlockId: BlockId, localEvents: [LocalEvent]) {
        self.textService.merge(contextID: documentId, firstBlockID: firstBlockId, secondBlockID: secondBlockId)
            .receiveOnMain()
            .sinkWithDefaultCompletion("blocksActions.service.merge with payload") { [weak self] serviceSuccess in
                var events = serviceSuccess.defaultEvent
                events.localEvents = localEvents
                self?.didReceiveEvent(events)
            }.store(in: &self.subscriptions)
    }
}

// MARK: - BookmarkFetch

extension BlockActionService {
    func bookmarkFetch(blockId: BlockId, url: String) {
        self.bookmarkService.fetchBookmark.action(contextID: self.documentId, blockID: blockId, url: url)
            .sinkWithDefaultCompletion("blocksActions.service.bookmarkFetch") { [weak self] serviceSuccess in
                self?.didReceiveEvent(serviceSuccess.defaultEvent)
        }.store(in: &self.subscriptions)
    }
}

// MARK: - SetBackgroundColor

extension BlockActionService {
    func setBackgroundColor(blockId: BlockId, color: BlockBackgroundColor) {
        setBackgroundColor(blockId: blockId, color: color.middleware)
    }
    
    func setBackgroundColor(blockId: BlockId, color: MiddlewareColor) {
        let blockIds = [blockId]

        listService.setBackgroundColor(contextID: self.documentId, blockIds: blockIds, color: color)
            .sinkWithDefaultCompletion("listService.setBackgroundColor") { [weak self] serviceSuccess in
                self?.didReceiveEvent(serviceSuccess.defaultEvent)
            }
            .store(in: &self.subscriptions)
    }
}

// MARK: - UploadFile

extension BlockActionService {
    func upload(blockId: BlockId, filePath: String) {
        fileService.uploadDataAtFilePath(contextID: self.documentId, blockID: blockId, filePath: filePath)
            .sinkWithDefaultCompletion("fileService.uploadDataAtFilePath") { [weak self] serviceSuccess in
                self?.didReceiveEvent(serviceSuccess.defaultEvent)
        }.store(in: &self.subscriptions)
    }
}
