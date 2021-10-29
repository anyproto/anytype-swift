import Combine
import BlocksModels
import UIKit
import Amplitude
import AnytypeCore
import ProtobufMessages


extension LoggerCategory {
    static let blockActionService: Self = "blockActionService"
}

final class BlockActionService: BlockActionServiceProtocol {
    private let documentId: BlockId

    private var subscriptions: [AnyCancellable] = []
    private let singleService = ServiceLocator.shared.blockActionsServiceSingle()
    private let pageService = ObjectActionsService()
    private let textService = TextService()
    private let listService = BlockListService()
    private let bookmarkService = BookmarkService()
    private let fileService = BlockActionsServiceFile()

    init(documentId: String) {
        self.documentId = documentId
    }
    
    /// Method to handle our events from outside of action service
    ///
    /// - Parameters:
    ///   - events: Event to handle
    func receivelocalEvents(_ events: [LocalEvent]) {
        EventsBunch(objectId: documentId, localEvents: events).send()
    }

    // MARK: Actions/Add

    func addChild(info: BlockInformation, parentBlockId: BlockId) {
        add(info: info, targetBlockId: parentBlockId, position: .inner, shouldSetFocusOnUpdate: true)
    }

    func add(info: BlockInformation, targetBlockId: BlockId, position: BlockPosition, shouldSetFocusOnUpdate: Bool) {
        guard let response = singleService
                .add(contextId: documentId, targetId: targetBlockId, info: info, position: position) else { return }
        
        let event = shouldSetFocusOnUpdate ? response.addEvent : response.asEventsBunch
        event.send()
    }

    func split(
        info: BlockInformation,
        oldText: String,
        newBlockContentType: BlockText.Style
    ) {
        let blockId = info.id
        // We are using old text as a cursor position.
        let position = oldText.count

        let content = info.content
        guard case let .text(blockText) = content else {
            anytypeAssertionFailure("We have unsupported content type: \(content)")
            return
        }

        let range = NSRange(location: position, length: 0)
        let documentId = self.documentId
        
        // if splitted block has child then new block should be child of splitted block
        let mode: Anytype_Rpc.Block.Split.Request.Mode = info.childrenIds.count > 0 ? .inner : .bottom

        guard textService.setText(
            contextId: documentId,
            blockId: blockId,
            middlewareString: MiddlewareString(text: blockText.text, marks: blockText.marks)
        ).isNotNil else { return }
            
        guard let splitSuccess = textService.split(
            contextId: documentId,
            blockId: blockId,
            range: range,
            style: newBlockContentType,
            mode: mode
        ) else { return }
            
        EventsBunch(
            objectId: documentId,
            middlewareEvents: splitSuccess.responseEvent.messages,
            localEvents: [
                .setFocus(blockId: splitSuccess.blockId, position: .beginning)
            ]
        ).send()
    }

    func duplicate(blockId: BlockId) {        
        singleService
            .duplicate(
                contextId: documentId,
                targetId: blockId,
                blockIds: [blockId],
                position: .bottom
            )
            .flatMap {
                EventsBunch(objectId: documentId, middlewareEvents: $0.messages).send()
            }
    }

    func createPage(targetId: BlockId, position: BlockPosition) -> BlockId? {
        let defaultTypeUrl = ObjectTypeProvider.defaultObjectType.url
        guard let newBlockId = pageService.createPage(
            contextId: documentId,
            targetId: targetId,
            details: [ObjectDetailsItem.name(""), ObjectDetailsItem.type(defaultTypeUrl)],
            position: position,
            templateId: ""
        ) else { return nil }
        
        Amplitude.instance().logEvent(AmplitudeEventsName.blockCreatePage)
        return newBlockId
    }

    func turnInto(blockId: BlockId, type: BlockContentType, shouldSetFocusOnUpdate: Bool) {
        switch type {
        case .text(let style):
            setTextStyle(blockId: blockId, style: style, shouldFocus: shouldSetFocusOnUpdate)
        case .smartblock:
            anytypeAssertionFailure("Use turnIntoPage action instead")
            _ = turnIntoPage(blockId: blockId)
        case .divider(let style): setDividerStyle(blockId: blockId, style: style)
        case .bookmark, .file, .layout, .link, .featuredRelations:
            anytypeAssertionFailure("TurnInto for that style is not implemented \(type)")
        }
    }
    
    func turnIntoPage(blockId: BlockId) -> BlockId? {
        return pageService
            .convertChildrenToPages(contextID: documentId, blocksIds: [blockId], objectType: "")?
            .first
    }
    
    func checked(blockId: BlockId, newValue: Bool) {
        textService.checked(contextId: documentId, blockId: blockId, newValue: newValue)
    }
    
    func delete(blockId: BlockId, previousBlockId: BlockId?) {
        guard
            let response = singleService.delete(
                contextId: documentId,
                blockIds: [blockId]
            )
        else {
            return
        }
        
        let localEvents: [LocalEvent] = previousBlockId.flatMap {
            [ .setFocus(blockId: $0, position: .end) ]
        } ?? []
        
        EventsBunch(
            objectId: documentId,
            middlewareEvents: response.messages,
            localEvents: localEvents
        ).send()
    }
    
    func setFields(contextID: BlockId, blockFields: [BlockFields]) {
        listService.setFields(contextId: contextID, fields: blockFields)
    }
    
    func setObjectTypeUrl(_ objectTypeUrl: String) {
        pageService.setObjectType(objectId: documentId, objectTypeUrl: objectTypeUrl)
    }
}

private extension BlockActionService {

    func setDividerStyle(blockId: BlockId, style: BlockDivider.Style) {
        listService.setDivStyle(contextId: documentId, blockIds: [blockId], style: style)
    }

    func setTextStyle(blockId: BlockId, style: BlockText.Style, shouldFocus: Bool) {
        guard let response = textService.setStyle(contextId: documentId, blockId: blockId, style: style) else {
            return
        }
        
        let events = shouldFocus ? response.turnIntoTextEvent : response.asEventsBunch
        events.send()
    }
}

// MARK: - Delete

extension BlockActionService {
    func merge(firstBlockId: BlockId, secondBlockId: BlockId, localEvents: [LocalEvent]) {
        guard let events = textService
                .merge(contextId: documentId, firstBlockId: firstBlockId, secondBlockId: secondBlockId) else {
                    return
                }
            
        events.enrichedWith(localEvents: localEvents).send()
    }
}

// MARK: - BookmarkFetch

extension BlockActionService {
    func bookmarkFetch(blockId: BlockId, url: String) {
        Amplitude.instance().logEvent(AmplitudeEventsName.blockBookmarkFetch)
        bookmarkService.fetchBookmark(contextID: self.documentId, blockID: blockId, url: url)
    }
}

// MARK: - SetBackgroundColor

extension BlockActionService {
    func setBackgroundColor(blockId: BlockId, color: BlockBackgroundColor) {
        setBackgroundColor(blockId: blockId, color: color.middleware)
    }
    
    func setBackgroundColor(blockId: BlockId, color: MiddlewareColor) {
        listService.setBackgroundColor(contextId: documentId, blockIds: [blockId], color: color)
    }
}

// MARK: - UploadFile

extension BlockActionService {
    func upload(blockId: BlockId, filePath: String) {
        fileService.asyncUploadDataAt(
            filePath: filePath,
            contextID: self.documentId,
            blockID: blockId
        )
            .sinkWithDefaultCompletion("fileService.uploadDataAtFilePath") { serviceSuccess in
                serviceSuccess.asEventsBunch.send()
        }.store(in: &self.subscriptions)
    }
}
