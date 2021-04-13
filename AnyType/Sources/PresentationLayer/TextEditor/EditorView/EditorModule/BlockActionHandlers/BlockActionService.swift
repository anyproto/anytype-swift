import Combine
import BlocksModels
import os
import UIKit

extension LoggerCategory {
    static let textEditorUserInteractor: Self = "TextEditor.UserInteraction"
}

/// Each method should return not a block, but a response.
/// Next, this response would be proceed by event handler.
final class BlockActionService {
    typealias ActionsPayload = BlocksViews.Base.ViewModel.ActionsPayload
    typealias Information = BlockInformation.InformationModel
    typealias Conversion = (ServiceSuccess) -> (EventListening.PackOfEvents)
    typealias BlockContentTypeText = BlockContent.Text.ContentType

    struct Converter {
        struct Default {
            func callAsFunction(_ value: ServiceSuccess) -> EventListening.PackOfEvents {
                .init(contextId: value.contextID, events: value.messages, ourEvents: [])
            }
            static let `default`: Self = .init()
            static func convert(_ value: ServiceSuccess) -> EventListening.PackOfEvents {
                self.default(value)
            }
        }
        struct Add {
            func callAsFunction(_ value: ServiceSuccess) -> EventListening.PackOfEvents {
                let addEntryMessage = value.messages.first { $0.value == .blockAdd($0.blockAdd) }

                guard let addedBlock = addEntryMessage?.blockAdd.blocks.first else {
                    return .init(contextId: value.contextID, events: value.messages, ourEvents: [])
                }

                let nextBlockId = addedBlock.id

                return .init(contextId: value.contextID, events: value.messages, ourEvents: [
                    .setFocus(.init(payload: .init(blockId: nextBlockId, position: .beginning)))
                ])
            }
            static let `default`: Self = .init()
            static func convert(_ value: ServiceSuccess) -> EventListening.PackOfEvents {
                self.default(value)
            }
        }
        struct Split {
            func callAsFunction(_ value: ServiceSuccess) -> EventListening.PackOfEvents {
                /// Find added block.
                let addEntryMessage = value.messages.first { $0.value == .blockAdd($0.blockAdd) }
                guard let addedBlock = addEntryMessage?.blockAdd.blocks.first else {
                    assertionFailure("blocks.split.afterUpdate can't find added block")
                    return .init(contextId: value.contextID, events: value.messages, ourEvents: [])
                }

                /// Find set children ids.
                let setChildrenMessage = value.messages.first { $0.value == .blockSetChildrenIds($0.blockSetChildrenIds)}
                guard let setChildrenEvent = setChildrenMessage?.blockSetChildrenIds else {
                    assertionFailure("blocks.split.afterUpdate can't find set children event")
                    return .init(contextId: value.contextID, events: value.messages, ourEvents: [])
                }

                let addedBlockId = addedBlock.id

                /// Find a block after added block, because we insert previous block.
                guard let addedBlockIndex = setChildrenEvent.childrenIds.firstIndex(where: { $0 == addedBlockId }) else {
                    assertionFailure("blocks.split.afterUpdate can't find index of added block in children ids.")
                    return .init(contextId: value.contextID, events: value.messages, ourEvents: [])
                }

                /// If we are adding as bottom, we don't need to find block after added block.
                /// Our addedBlockIndex is focused index.
                let focusedIndex = addedBlockIndex
                //setChildrenEvent.childrenIds.index(after: addedBlockIndex)

                /// Check that our childrenIds collection indices contains index.
                guard setChildrenEvent.childrenIds.indices.contains(focusedIndex) else {
                    assertionFailure("blocks.split.afterUpdate children ids doesn't contain index of focused block.")
                    return .init(contextId: value.contextID, events: value.messages, ourEvents: [])
                }

                let focusedBlockId = setChildrenEvent.childrenIds[focusedIndex]

                return .init(contextId: value.contextID, events: value.messages, ourEvents: [
                    .setFocus(.init(payload: .init(blockId: focusedBlockId, position: .beginning)))
                ])
            }
            static let `default`: Self = .init()
            static func convert(_ value: ServiceSuccess) -> EventListening.PackOfEvents {
                self.default(value)
            }
        }
        struct TurnInto {
            struct Text {
                func callAsFunction(_ value: ServiceSuccess) -> EventListening.PackOfEvents {
                    let textMessage = value.messages.first { $0.value == .blockSetText($0.blockSetText) }

                    guard let changedBlock = textMessage?.blockSetText else {
                        return .init(contextId: value.contextID, events: value.messages, ourEvents: [])
                    }

                    let focusedBlockId = changedBlock.id

                    return .init(contextId: value.contextID, events: value.messages, ourEvents: [
                        .setFocus(.init(payload: .init(blockId: focusedBlockId, position: .beginning)))
                    ])
                }
                static let `default`: Self = .init()
                static func convert(_ value: ServiceSuccess) -> EventListening.PackOfEvents {
                    self.default(value)
                }
            }
        }

        struct Delete {
            func callAsFunction(_ value: ServiceSuccess) -> EventListening.PackOfEvents {
                .init(contextId: value.contextID, events: value.messages, ourEvents: [])
            }
            static let `default`: Self = .init()
            static func convert(_ value: ServiceSuccess) -> EventListening.PackOfEvents {
                self.default(value)
            }
        }
    }

    private var documentId: String

    private var subscriptions: [AnyCancellable] = []
    private let service: BlockActionsServiceSingle = .init()
    private let pageService: ObjectActionsService = .init()
    private let textService: BlockActionsServiceText = .init()
    private let listService: BlockActionsServiceList = .init()
    private let bookmarkService: BlockActionsServiceBookmark = .init()
    private let fileService: BlockActionsServiceFile = .init()

    private var didReceiveEvent: (BlockActionsHandlersFacade.ActionType?, EventListening.PackOfEvents) -> () = { _,_  in }

    // We also need a handler of events.
    private let eventHandling: String = ""

    init(documentId: String) {
        self.documentId = documentId
    }
    
    /// Method to handle our events from outside of action service
    ///
    /// - Parameters:
    ///   - events: Event to handle
    func receiveOurEvents(_ events: [EventListening.OurEvent]) {
        self.didReceiveEvent(nil, .init(contextId: documentId, events: [], ourEvents: events))
    }

    func configured(documentId: String) -> Self {
        self.documentId = documentId
        return self
    }

    func configured(didReceiveEvent: @escaping (BlockActionsHandlersFacade.ActionType?, EventListening.PackOfEvents) -> ()) -> Self {
        self.didReceiveEvent = didReceiveEvent
        return self
    }

    // MARK: Actions/Add

    func addChild(childBlock: Information, parentBlockId: BlockId) {
        // insert block as child to parent.
        self.add(newBlock: childBlock, afterBlockId: parentBlockId, position: .inner, shouldSetFocusOnUpdate: true)
    }

    func add(newBlock: Information, afterBlockId: BlockId, position: BlockPosition = .bottom, shouldSetFocusOnUpdate: Bool) {
        let conversion: Conversion = shouldSetFocusOnUpdate ? Converter.Add.convert : Converter.Default.convert
        _add(newBlock: newBlock, afterBlockId: afterBlockId, position: position, conversion)
    }

    func split(block: Information,
               oldText: String,
               newBlockContentType: BlockContentTypeText,
               shouldSetFocusOnUpdate: Bool) {
        let conversion: Conversion = shouldSetFocusOnUpdate ? Converter.Split.convert : Converter.Default.convert
        _setTextAndSplit(block: block,
                         oldText: oldText,
                         newBlockContentType: newBlockContentType,
                         conversion)
    }

    func duplicate(block: Information) {
        let targetId = block.id
        let blockIds: [String] = [targetId]
        let position: BlockPosition = .bottom
        self.service.duplicate(contextID: self.documentId, targetID: targetId, blockIds: blockIds, position: position).sink(receiveCompletion: { (value) in
            switch value {
            case .finished: return
            case let .failure(error):
                assertionFailure("blocksActions.service.duplicate got error: \(error)")
            }
        }) { [weak self] (value) in
            self?.didReceiveEvent(nil, .init(contextId: value.contextID, events: value.messages))
        }.store(in: &self.subscriptions)
    }

    func createPage(afterBlock: Information, position: BlockPosition = .bottom) {

        let targetId = ""
        let details: DetailsInformationModelProtocol = TopLevelBuilderImpl.detailsBuilder.informationBuilder.build(list: [
            .title(.init()),
            .iconEmoji(.init())
        ])

        self.pageService.createPage(contextID: self.documentId, targetID: targetId, details: details, position: position)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (value) in
                switch value {
                case .finished: return // move to this page
                case let .failure(error):
                    assertionFailure("blocksActions.service.createPage with payload got error: \(error)")
                }
            }) { [weak self] (value) in
                self?.didReceiveEvent(nil, .init(contextId: value.contextID, events: value.messages))
            }.store(in: &self.subscriptions)
    }

    /// Turn Into
    // TODO: Add Div and ConvertChildrenToPages
    func turnInto(block: Information, type: BlockContent, shouldSetFocusOnUpdate: Bool) {
        /// Also check for style later.
        let conversion: Conversion = shouldSetFocusOnUpdate ? Converter.TurnInto.Text.convert : Converter.Default.convert
        _turnInto(block: block, type: type, conversion)
    }
    
    /// Set checkbox state for block
    ///
    /// - Parameters:
    ///   - block: Block to change checkbox state
    ///   - newValue: New value of checkbox
    func checked(block: BlockActiveRecordModelProtocol, newValue: Bool) {
        self.textService.checked(
            contextId: self.documentId,
            blockId: block.blockModel.information.id,
            newValue: newValue
        )
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { value in
                switch value {
                case .finished: break
                case let .failure(error):
                    os_log(.error, "textService.checked got error with payload: \(error.localizedDescription)")
                }
            }) { [weak self] value in
                self?.didReceiveEvent(nil, .init(contextId: value.contextID, events: value.messages))
            }.store(in: &self.subscriptions)
    }
}

private extension BlockActionService {
    func _add(newBlock: Information, afterBlockId: BlockId, position: BlockPosition = .bottom, _ completion: @escaping Conversion) {

        // insert block after block
        // we could catch events and update model.
        // or we could just update model after sending event.
        // for now we just update model on success.

        let targetId = afterBlockId

        self.service.add(contextID: self.documentId, targetID: targetId, block: newBlock, position: position)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (value) in
                switch value {
                case .finished: return
                case let .failure(error):
                    assertionFailure("blocksActions.service.add got error: \(error)")
                }
            }) { [weak self] (value) in
                let value = completion(value)
                self?.didReceiveEvent(nil, value)
            }.store(in: &self.subscriptions)
    }


    func _split(block: Information, oldText: String, _ completion: @escaping Conversion) {
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
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (value) in
                switch value {
                case .finished: return
                case let .failure(error):
                    assertionFailure("blocksActions.service.split without payload got error: \(error)")
                }
            }, receiveValue: { [weak self] (value) in
                let value = completion(value)
                self?.didReceiveEvent(nil, value)
            }).store(in: &self.subscriptions)
    }

    func _setTextAndSplit(block: Information,
                          oldText: String,
                          newBlockContentType: BlockContentTypeText,
                          _ completion: @escaping Conversion) {
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
        }).sink { (value) in
            switch value {
            case .finished: return
            case let .failure(error):
                assertionFailure("blocksActions.service.setTextAndSplit got error: \(error)")
            }
        } receiveValue: { [weak self] (value) in
            let value = completion(value)
            var theValue = value
            theValue.ourEvents = [.setTextMerge(.init(payload: .init(blockId: blockId)))] + theValue.ourEvents
            self?.didReceiveEvent(nil, theValue)
        }.store(in: &self.subscriptions)
    }

    // MARK: Delete
    func _delete(block: Information, _ completion: @escaping Conversion) {
        let blockIds = [block.id]
        self.service.delete(contextID: self.documentId, blockIds: blockIds)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (value) in
                switch value {
                case .finished: return
                case let .failure(error):
                    // It occurs if you press delete at the beginning of title block
                    Logger.create(.textEditorUserInteractor).debug(
                        "blocksActions.service.delete without payload got error: \(error.localizedDescription)"
                    )
                }
            }, receiveValue: { [weak self] value in
                let value = completion(value)
                self?.didReceiveEvent(.deleteBlock, value)
            }).store(in: &self.subscriptions)
    }

    // MARK: - Turn Into
    func _turnInto(block: Information, type: BlockContent, _ completion: @escaping Conversion = Converter.Default.convert) {
        switch type {
        case .text: self.setTextStyle(block: block, type: type, completion)
        case .smartblock: self.setPageStyle(block: block, type: type)
        case .divider: self.setDividerStyle(block: block, type: type, completion)
        default: return
        }
    }

    private func setDividerStyle(block: Information, type: BlockContent, _ completion: @escaping Conversion = Converter.Default.convert) {
        let blockId = block.id
        guard case let .divider(value) = type else {
            assertionFailure("SetDividerStyle content is not divider: \(type)")
            return
        }

        let blocksIds = [blockId]

        self.listService.setDivStyle.action(contextID: self.documentId, blockIds: blocksIds, style: value.style).sink(receiveCompletion: { (value) in
            switch value {
            case .finished: return
            case let .failure(error):
                assertionFailure("blocksActions.service.turnInto.setDivStyle got error: \(error)")
            }
        }) { [weak self] (value) in
            let value = completion(value)
            self?.didReceiveEvent(nil, value)
        }.store(in: &self.subscriptions)
    }

    private func setPageStyle(block: Information, type: BlockContent) {
        let blockId = block.id

        guard case .smartblock = type else {
            assertionFailure("Set Page style cannot convert type: \(type)")
            return
        }

        let blocksIds = [blockId]

        self.pageService.convertChildrenToPages(contextID: self.documentId, blocksIds: blocksIds).sink(receiveCompletion: { (value) in
            switch value {
            case .finished: return
            case let .failure(error):
                assertionFailure("blocksActions.service.turnInto.convertChildrenToPages got error: \(error)")
            }
        }, receiveValue: { _ in }).store(in: &self.subscriptions)
    }

    private func setTextStyle(block: Information, type: BlockContent, _ completion: @escaping Conversion = Converter.Default.convert) {
        let blockId = block.id

        guard case let .text(text) = type else {
            assertionFailure("Set Text style content is not text style: \(type)")
            return
        }

        self.textService.setStyle(contextID: self.documentId, blockID: blockId, style: text.contentType)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (value) in
                switch value {
                case .finished: return
                case let .failure(error):
                    assertionFailure("blocksActions.service.turnInto.setTextStyle got error: \(error)")
                }
            }) { [weak self] (value) in
                let value = completion(value)
                self?.didReceiveEvent(nil, value)
            }.store(in: &self.subscriptions)
    }
}

// MARK: - Delete

extension BlockActionService {
    func delete(block: Information, completion: @escaping Conversion) {
        _delete(block: block, completion)
    }

    func merge(firstBlock: Information, secondBlock: Information, _ completion: @escaping Conversion = Converter.Default.convert) {
        let firstBlockId = firstBlock.id
        let secondBlockId = secondBlock.id

        self.textService.merge(contextID: self.documentId, firstBlockID: firstBlockId, secondBlockID: secondBlockId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { value in
                switch value {
                case .finished: return
                case let .failure(error):
                    assertionFailure("blocksActions.service.merge with payload got error: \(error)")
                }
            }, receiveValue: { [weak self] value in
                let value = completion(value)
                self?.didReceiveEvent(.merge, value)
            }).store(in: &self.subscriptions)
    }
}

// MARK: - BookmarkFetch

extension BlockActionService {
    private func _bookmarkFetch(block: Information, url: String, _ completion: @escaping Conversion = Converter.Default.convert) {
        let blockId = block.id
        self.bookmarkService.fetchBookmark.action(contextID: self.documentId, blockID: blockId, url: url).sink(receiveCompletion: { (value) in
            switch value {
            case .finished: return
            case let .failure(error):
                assertionFailure("blocksActions.service.bookmarkFetch got error: \(error)")
            }
        }) { [weak self] (value) in
            let value = completion(value)
            self?.didReceiveEvent(nil, value)
        }.store(in: &self.subscriptions)
    }

    func bookmarkFetch(block: Information, url: String) {
        self._bookmarkFetch(block: block, url: url)
    }
}

// MARK: - SetBackgroundColor

extension BlockActionService {
    private func _setBackgroundColor(block: Information, color: UIColor, _ completion: @escaping Conversion = Converter.Default.convert) {
        guard let color = MiddlewareModelsModule.Parsers.Text.Color.Converter.asMiddleware(color, background: true) else {            assertionFailure("Wrong UIColor for setBackgroundColor command")
            return
        }

        let blockId = block.id
        let blockIds = [blockId]
        let backgroundColor = color

        self.listService.setBackgroundColor.action(contextID: self.documentId, blockIds: blockIds, color: backgroundColor)
            .sink { (value) in
                switch value {
                case .finished: return
                case let .failure(error):
                    assertionFailure("listService.setBackgroundColor got error: \(error)")
                }
            } receiveValue: { [weak self] (value) in
                let value = completion(value)
                self?.didReceiveEvent(nil, value)
            }
            .store(in: &self.subscriptions)
    }

    func setBackgroundColor(block: Information, color: UIColor) {
        self._setBackgroundColor(block: block, color: color)
    }
}

// MARK: - UploadFile

extension BlockActionService {
    private func _upload(block: Information, filePath: String, _ completion: @escaping Conversion = Converter.Default.convert) {
        let blockId = block.id
        self.fileService.uploadDataAtFilePath.action(contextID: self.documentId, blockID: blockId, filePath: filePath).sink { (value) in
            switch value {
            case .finished: return
            case let .failure(error):
                assertionFailure("fileService.uploadDataAtFilePath got error: \(error)")
            }
        } receiveValue: { [weak self] (value) in
            let value = completion(value)
            self?.didReceiveEvent(nil, value)
        }.store(in: &self.subscriptions)
    }
    
    func upload(block: Information, filePath: String) {
        self._upload(block: block, filePath: filePath)
    }
}
