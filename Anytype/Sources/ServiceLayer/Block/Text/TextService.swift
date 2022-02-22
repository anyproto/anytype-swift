import Foundation
import Combine
import UIKit
import ProtobufMessages
import BlocksModels
import Amplitude

final class TextService: TextServiceProtocol {    
    func setText(contextId: String, blockId: String, middlewareString: MiddlewareString) {
        Amplitude.instance().logEvent(AmplitudeEventsName.blockSetTextText)
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
        Amplitude.instance().logEvent(AmplitudeEventsName.blockSetTextText)
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
        Amplitude.instance().logSetStyle(style)
        Anytype_Rpc.Block.Set.Text.Style.Service
            .invoke(contextID: contextId, blockID: blockId, style: style.asMiddleware)
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .textService)?
            .send()
    }
    
    func split(contextId: BlockId, blockId: BlockId, range: NSRange, style: Style, mode: SplitMode) -> BlockId? {
        let textContentType = BlockContent.text(.empty(contentType: style)).description
        Amplitude.instance().logCreateBlock(type: textContentType, style: String(describing: style))

        let response = Anytype_Rpc.Block.Split.Service
            .invoke(contextID: contextId, blockID: blockId, range: range.asMiddleware, style: style.asMiddleware, mode: mode)
            .getValue(domain: .textService)
        
        guard let response = response else {
            return nil
        }

        EventsBunch(event: response.event).send()
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
    
}
