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

    private var didReceiveEvent: (BlockActionServiceReaction.ActionType?, PackOfEvents) -> () = { _,_  in }

    init(documentId: String) {
        self.documentId = documentId
    }
    
    /// Method to handle our events from outside of action service
    ///
    /// - Parameters:
    ///   - events: Event to handle
    func receiveOurEvents(_ events: [OurEvent]) {
        self.didReceiveEvent(nil, .init(contextId: documentId, events: [], ourEvents: events))
    }

    func configured(documentId: String) -> Self {
        self.documentId = documentId
        return self
    }

    @discardableResult
    func configured(didReceiveEvent: @escaping (BlockActionServiceReaction.ActionType?, PackOfEvents) -> ()) -> Self {
        self.didReceiveEvent = didReceiveEvent
        return self
    }

    // MARK: Actions/Add

    func addChild(childBlock: BlockInformation, parentBlockId: BlockId) {
        // insert block as child to parent.
        self.add(newBlock: childBlock, afterBlockId: parentBlockId, position: .inner, shouldSetFocusOnUpdate: true)
    }

    func add(newBlock: BlockInformation, afterBlockId: BlockId, position: BlockPosition = .bottom, shouldSetFocusOnUpdate: Bool) {
        let conversion: Conversion = shouldSetFocusOnUpdate ? Converter.Add.convert : Converter.Default.convert
        add(newBlock: newBlock, afterBlockId: afterBlockId, position: position, conversion)
    }

    func split(block: BlockInformation,
               oldText: String,
               newBlockContentType: BlockText.ContentType,
               shouldSetFocusOnUpdate: Bool) {
        let conversion: Conversion = shouldSetFocusOnUpdate ? Converter.Split.convert : Converter.Default.convert
        setTextAndSplit(block: block, oldText: oldText, newBlockContentType: newBlockContentType, conversion)
    }

    func duplicate(block: BlockInformation) {
        let targetId = block.id
        let blockIds: [String] = [targetId]
        let position: BlockPosition = .bottom
        
        singleService.duplicate(
            contextID: documentId,
            targetID: targetId,
            blockIds: blockIds,
            position: position
        ).sinkWithDefaultCompletion("blocksActions.service.duplicate") { [weak self] (value) in
            self?.didReceiveEvent(nil, .init(contextId: value.contextID, events: value.messages))
        }.store(in: &self.subscriptions)
    }

    func createPage(afterBlock: BlockInformation, position: BlockPosition = .bottom) {
        self.pageService.createPage(contextID: self.documentId,
                                    targetID: "",
                                    details: [.name: DetailsEntry(value: "")],
                                    position: position,
                                    templateID: "")
            .receiveOnMain()
            .sinkWithDefaultCompletion("blocksActions.service.createPage with payload") { [weak self] (value) in
                self?.didReceiveEvent(nil, .init(contextId: value.contextID, events: value.messages))
            }.store(in: &self.subscriptions)
    }

    /// Turn Into
    // TODO: Add Div and ConvertChildrenToPages
    func turnInto(block: BlockInformation, type: BlockContent, shouldSetFocusOnUpdate: Bool) {
        /// Also check for style later.
        let conversion: Conversion = shouldSetFocusOnUpdate ? Converter.TurnInto.Text.convert : Converter.Default.convert
        turnInto(block: block, type: type, conversion)
    }
    
    /// Set checkbox state for block
    ///
    /// - Parameters:
    ///   - block: Block to change checkbox state
    ///   - newValue: New value of checkbox
    func checked(block: BlockActiveRecordModelProtocol, newValue: Bool) {
        self.textService.checked(
            contextId: self.documentId,
            blockId: block.blockId,
            newValue: newValue
        )
            .receiveOnMain()
            .sinkWithDefaultCompletion("textService.checked with payload") { [weak self] value in
                self?.didReceiveEvent(nil, .init(contextId: value.contextID, events: value.messages))
            }.store(in: &self.subscriptions)
    }
    
    func delete(block: BlockInformation, completion: @escaping Conversion) {
        let blockIds = [block.id]
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
                self?.didReceiveEvent(.deleteBlock, value)
            }.store(in: &self.subscriptions)
    }
}

private extension BlockActionService {
    func add(newBlock: BlockInformation, afterBlockId: BlockId, position: BlockPosition = .bottom, _ completion: @escaping Conversion) {

        // insert block after block
        // we could catch events and update model.
        // or we could just update model after sending event.
        // for now we just update model on success.

        let targetId = afterBlockId

        singleService.add(contextID: self.documentId, targetID: targetId, block: newBlock, position: position)
            .receiveOnMain()
            .sinkWithDefaultCompletion("blocksActions.service.add") { [weak self] (value) in
                let value = completion(value)
                self?.didReceiveEvent(nil, value)
            }.store(in: &self.subscriptions)
    }


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

        let range: NSRange = .init(location: position, length: 0)

        self.textService.split(contextID: self.documentId, blockID: blockId, range: range, style: type.contentType)
            .receiveOnMain()
            .sinkWithDefaultCompletion("blocksActions.service.split without payload") { [weak self] (value) in
                let value = completion(value)
                self?.didReceiveEvent(nil, value)
            }.store(in: &self.subscriptions)
    }

    func setTextAndSplit(
        block: BlockInformation,
        oldText: String,
        newBlockContentType: BlockText.ContentType,
        _ completion: @escaping Conversion
    ) {
        // TODO: "You should update parameter `oldText`. It shouldn't be a plain `String`. It should be either `Int32` to reflect cursor position or it should be `NSAttributedString`." )

        let blockId = block.id
        // We are using old text as a cursor position.
        let position = oldText.count

        let content = block.content
        guard case let .text(type) = content else {
            assertionFailure("We have unsupported content type: \(content)")
            return
        }

        let range: NSRange = .init(location: position, length: 0)

        let documentId = self.documentId

        self.textService.setText(contextID: documentId, blockID: blockId, attributedString: type.attributedText).flatMap({ [weak self] value -> AnyPublisher<ServiceSuccess, Error> in
            return self?.textService.split(
                contextID: documentId,
                blockID: blockId,
                range: range,
                style: newBlockContentType) ?? .empty()
        }).sinkWithDefaultCompletion("blocksActions.service.setTextAndSplit") { [weak self] (value) in
            let value = completion(value)
            var theValue = value
            theValue.ourEvents = [.setTextMerge(.init(blockId: blockId))] + theValue.ourEvents
            self?.didReceiveEvent(nil, theValue)
        }.store(in: &self.subscriptions)
    }

    func turnInto(block: BlockInformation, type: BlockContent, _ completion: @escaping Conversion = Converter.Default.convert) {
        switch type {
        case .text: self.setTextStyle(block: block, type: type, completion)
        case .smartblock: self.setPageStyle(block: block, type: type)
        case .divider: self.setDividerStyle(block: block, type: type, completion)
        default: return
        }
    }

    func setDividerStyle(block: BlockInformation, type: BlockContent, _ completion: @escaping Conversion = Converter.Default.convert) {
        let blockId = block.id
        guard case let .divider(value) = type else {
            assertionFailure("SetDividerStyle content is not divider: \(type)")
            return
        }

        let blocksIds = [blockId]

        listService.setDivStyle(contextID: self.documentId, blockIds: blocksIds, style: value.style)
            .sinkWithDefaultCompletion("blocksActions.service.turnInto.setDivStyle") { [weak self] (value) in
            let value = completion(value)
            self?.didReceiveEvent(nil, value)
        }.store(in: &self.subscriptions)
    }

    func setPageStyle(block: BlockInformation, type: BlockContent) {
        let blockId = block.id
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

    func setTextStyle(block: BlockInformation, type: BlockContent, _ completion: @escaping Conversion = Converter.Default.convert) {
        let blockId = block.id

        guard case let .text(text) = type else {
            assertionFailure("Set Text style content is not text style: \(type)")
            return
        }

        self.textService.setStyle(contextID: self.documentId, blockID: blockId, style: text.contentType)
            .receiveOnMain()
            .sinkWithDefaultCompletion("blocksActions.service.turnInto.setTextStyle") { [weak self] value in
                let value = completion(value)
                self?.didReceiveEvent(nil, value)
            }.store(in: &self.subscriptions)
    }
}

// MARK: - Delete

extension BlockActionService {
    func merge(firstBlock: BlockInformation, secondBlock: BlockInformation, _ completion: @escaping Conversion = Converter.Default.convert) {
        let firstBlockId = firstBlock.id
        let secondBlockId = secondBlock.id

        self.textService.merge(contextID: self.documentId, firstBlockID: firstBlockId, secondBlockID: secondBlockId)
            .receiveOnMain()
            .sinkWithDefaultCompletion("blocksActions.service.merge with payload") { [weak self] value in
                let value = completion(value)
                self?.didReceiveEvent(.merge, value)
            }.store(in: &self.subscriptions)
    }
}

// MARK: - BookmarkFetch

extension BlockActionService {
    private func _bookmarkFetch(block: BlockInformation, url: String, _ completion: @escaping Conversion = Converter.Default.convert) {
        let blockId = block.id
        self.bookmarkService.fetchBookmark.action(contextID: self.documentId, blockID: blockId, url: url)
            .sinkWithDefaultCompletion("blocksActions.service.bookmarkFetch") { [weak self] (value) in
                let value = completion(value)
                self?.didReceiveEvent(nil, value)
        }.store(in: &self.subscriptions)
    }

    func bookmarkFetch(block: BlockInformation, url: String) {
        self._bookmarkFetch(block: block, url: url)
    }
}

// MARK: - SetBackgroundColor

extension BlockActionService {
    private func _setBackgroundColor(block: BlockInformation, color: UIColor, _ completion: @escaping Conversion = Converter.Default.convert) {
        guard let color = MiddlewareModelsModule.Parsers.Text.Color.Converter.asMiddleware(color, background: true) else {            assertionFailure("Wrong UIColor for setBackgroundColor command")
            return
        }

        let blockId = block.id
        let blockIds = [blockId]
        let backgroundColor = color

        listService.setBackgroundColor(contextID: self.documentId, blockIds: blockIds, color: backgroundColor)
            .sinkWithDefaultCompletion("listService.setBackgroundColor") { [weak self] (value) in
                let value = completion(value)
                self?.didReceiveEvent(nil, value)
            }
            .store(in: &self.subscriptions)
    }

    func setBackgroundColor(block: BlockInformation, color: UIColor) {
        self._setBackgroundColor(block: block, color: color)
    }
}

// MARK: - UploadFile

extension BlockActionService {
    private func _upload(block: BlockInformation, filePath: String, _ completion: @escaping Conversion = Converter.Default.convert) {
        let blockId = block.id
        self.fileService.uploadDataAtFilePath(contextID: self.documentId, blockID: blockId, filePath: filePath)
            .sinkWithDefaultCompletion("fileService.uploadDataAtFilePath") { [weak self] (value) in
                let value = completion(value)
                self?.didReceiveEvent(nil, value)
        }.store(in: &self.subscriptions)
    }
    
    func upload(block: BlockInformation, filePath: String) {
        self._upload(block: block, filePath: filePath)
    }
}
