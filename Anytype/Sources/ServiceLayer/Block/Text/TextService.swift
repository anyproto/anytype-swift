import Foundation
import ProtobufMessages
import BlocksModels
import AnytypeCore

final class TextService: TextServiceProtocol {    
    func setText(contextId: String, blockId: String, middlewareString: MiddlewareString) {
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.blockSetTextText)
        Anytype_Rpc.Block.Set.Text.Text.Service.invoke(
            contextID: contextId,
            blockID: blockId,
            text: middlewareString.text,
            marks: middlewareString.marks
        )
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .textService)?
            .send()
    }

    @discardableResult
    func setTextForced(contextId: BlockId, blockId: BlockId, middlewareString: MiddlewareString) -> Bool {
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.blockSetTextText)
        let event = Anytype_Rpc.Block.Set.Text.Text.Service
            .invoke(contextID: contextId, blockID: blockId, text: middlewareString.text, marks: middlewareString.marks)
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .textService)
        guard let event = event else {
            return false
        }

        event.send()
        return true
    }
    
    func setStyle(contextId: BlockId, blockId: BlockId, style: Style) {
        AnytypeAnalytics.instance().logSetStyle(style)
        let event = Anytype_Rpc.Block.Set.Text.Style.Service
            .invoke(contextID: contextId, blockID: blockId, style: style.asMiddleware)
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .textService)

        guard let anytypeId = AnytypeId(blockId) else { return }

        EventsBunch(
            contextId: contextId,
            middlewareEvents: event?.middlewareEvents ?? [],
            localEvents: [.setStyle(blockId: anytypeId)],
            dataSourceEvents: []
        ).send()
    }
    
    func split(contextId: BlockId, blockId: BlockId, nsRange: NSRange, style: Style, mode: SplitMode) -> BlockId? {
        let textContentType = BlockContent.text(.empty(contentType: style)).description
        AnytypeAnalytics.instance().logCreateBlock(type: textContentType, style: String(describing: style))

        let response = Anytype_Rpc.Block.Split.Service
            .invoke(contextID: contextId, blockID: blockId, range: nsRange.asMiddleware, style: style.asMiddleware, mode: mode)
            .getValue(domain: .textService)
        
        guard let response = response else {
            return nil
        }

        EventsBunch(
            contextId: contextId,
            middlewareEvents: response.event.messages,
            localEvents: [.general],
            dataSourceEvents: []
        ).send()

        return response.blockID
    }

    func merge(contextId: BlockId, firstBlockId: BlockId, secondBlockId: BlockId) -> Bool {
        let events = Anytype_Rpc.Block.Merge.Service
            .invoke(contextID: contextId, firstBlockID: firstBlockId, secondBlockID: secondBlockId)
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .textService)
            
        guard let events = events else { return false }
        events.send()
        return true
    }
    
    func checked(contextId: BlockId, blockId: BlockId, newValue: Bool) {
        Anytype_Rpc.Block.Set.Text.Checked.Service
            .invoke(contextID: contextId, blockID: blockId, checked: newValue)
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .textService)?
            .send()
    }

    func setTextIcon(
        contextId: BlockId,
        blockId: BlockId,
        imageHash: String,
        emojiUnicode: String
    ) {
        Anytype_Rpc.Block.Set.Text.Icon.Service.invoke(
            contextID: contextId,
            blockID: blockId,
            iconImage: imageHash,
            iconEmoji: emojiUnicode
        )
            .getValue(domain: .textService)
            .map(\.event)
            .map(EventsBunch.init)?
            .send()
    }
    
}
