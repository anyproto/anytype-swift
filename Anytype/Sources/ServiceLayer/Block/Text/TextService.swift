import Foundation
import Combine
import UIKit
import ProtobufMessages
import BlocksModels
import Amplitude

final class TextService: TextServiceProtocol {    

    @discardableResult
    func setText(contextId: String, blockId: String, middlewareString: MiddlewareString) -> MiddlewareResponse? {
        Amplitude.instance().logEvent(AmplitudeEventsName.blockSetTextText)
        return Anytype_Rpc.Block.Set.Text.Text.Service
            .invoke(contextID: contextId, blockID: blockId, text: middlewareString.text, marks: middlewareString.marks)
            .map { MiddlewareResponse($0.event) }
            .getValue()
    }
    
    func setStyle(contextId: BlockId, blockId: BlockId, style: Style) -> MiddlewareResponse? {
        Amplitude.instance().logEvent(
            AmplitudeEventsName.blockSetTextStyle,
            withEventProperties: [AmplitudeEventsPropertiesKey.blockStyle: String(describing: style)]
        )
        return Anytype_Rpc.Block.Set.Text.Style.Service
            .invoke(contextID: contextId, blockID: blockId, style: style.asMiddleware)
            .map { MiddlewareResponse($0.event) }
            .getValue()
    }
    
    func split(contextId: BlockId, blockId: BlockId, range: NSRange, style: Style, mode: SplitMode) -> BlockId? {
        Amplitude.instance().logEvent(AmplitudeEventsName.blockSplit)
        let response = Anytype_Rpc.Block.Split.Service
            .invoke(contextID: contextId, blockID: blockId, range: range.asMiddleware, style: style.asMiddleware, mode: mode)
            .getValue()
        
        guard let response = response else {
            return nil
        }

        EventsBunch(event: response.event).send()
        return response.blockID
    }

    func merge(contextId: BlockId, firstBlockId: BlockId, secondBlockId: BlockId) -> Bool {
        Amplitude.instance().logEvent(AmplitudeEventsName.blockMerge)
        let events = Anytype_Rpc.Block.Merge.Service
            .invoke(contextID: contextId, firstBlockID: firstBlockId, secondBlockID: secondBlockId)
            .map { EventsBunch(event: $0.event) }
            .getValue()
            
        guard let events = events else { return false }
        events.send()
        return true
    }
    
    func checked(contextId: BlockId, blockId: BlockId, newValue: Bool) {
        Amplitude.instance().logEvent(AmplitudeEventsName.blockSetTextChecked)
        Anytype_Rpc.Block.Set.Text.Checked.Service
            .invoke(contextID: contextId, blockID: blockId, checked: newValue)
            .map { EventsBunch(event: $0.event) }
            .getValue()?
            .send()
    }
    
}
