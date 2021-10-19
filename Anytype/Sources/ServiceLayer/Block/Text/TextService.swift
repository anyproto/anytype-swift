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
    
    @discardableResult
    func setForegroundColor(contextId: String, blockId: String, color: String) -> MiddlewareResponse? {
        Anytype_Rpc.Block.Set.Text.Color.Service.invoke(contextID: contextId, blockID: blockId, color: color)
            .map { MiddlewareResponse($0.event) }
            .getValue()
    }
    
    func split(
        contextId: BlockId,
        blockId: BlockId, range: NSRange,
        style: Style,
        mode: Anytype_Rpc.Block.Split.Request.Mode
    ) -> SplitSuccess? {
        Amplitude.instance().logEvent(AmplitudeEventsName.blockSplit)
        return Anytype_Rpc.Block.Split.Service.invoke(
            contextID: contextId, blockID: blockId, range: range.asMiddleware, style: style.asMiddleware, mode: mode)
            .map { SplitSuccess($0) }
            .getValue()
    }

    func merge(contextId: BlockId, firstBlockId: BlockId, secondBlockId: BlockId) -> MiddlewareResponse? {
        Amplitude.instance().logEvent(AmplitudeEventsName.blockMerge)
        return Anytype_Rpc.Block.Merge.Service.invoke(
            contextID: contextId, firstBlockID: firstBlockId, secondBlockID: secondBlockId
        )
            .map { MiddlewareResponse($0.event) }
            .getValue()
    }
    
    func checked(contextId: BlockId, blockId: BlockId, newValue: Bool) -> MiddlewareResponse? {
        Amplitude.instance().logEvent(AmplitudeEventsName.blockSetTextChecked)
        return Anytype_Rpc.Block.Set.Text.Checked.Service.invoke(
            contextID: contextId,
            blockID: blockId,
            checked: newValue
        )
            .map { MiddlewareResponse($0.event) }
            .getValue()
    }
    
}
