import Foundation
import Combine
import BlocksModels
import UIKit
import ProtobufMessages
import SwiftProtobuf
import Amplitude
import AnytypeCore

class BlockListService: BlockListServiceProtocol {
    func setBlockColor(contextId: BlockId, blockIds: [BlockId], color: MiddlewareColor) {
        Anytype_Rpc.BlockList.Set.Text.Color.Service
            .invoke(contextID: contextId, blockIds: blockIds, color: color.rawValue)
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .blockListService)?
            .send()
    }
    
    func setFields(contextId: BlockId, fields: [BlockFields]) {
        let middleFields = fields.map { $0.convertToMiddle() }
        Anytype_Rpc.BlockList.Set.Fields.Service
            .invoke(contextID: contextId, blockFields: middleFields)
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .blockListService)?
            .send()
    }

    func setBackgroundColor(contextId: BlockId, blockIds: [BlockId], color: MiddlewareColor) {
        Amplitude.instance().logEvent(AmplitudeEventsName.blockListSetBackgroundColor)

        Anytype_Rpc.BlockList.Set.BackgroundColor.Service
            .invoke(contextID: contextId, blockIds: blockIds, color: color.rawValue)
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .blockListService)?
            .send()
    }

    func setAlign(contextId: BlockId, blockIds: [BlockId], alignment: LayoutAlignment) {
        Amplitude.instance().logSetAlignment(alignment, isBlock: blockIds.isNotEmpty)

        Anytype_Rpc.BlockList.Set.Align.Service
            .invoke(contextID: contextId, blockIds: blockIds, align: alignment.asMiddleware)
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .blockListService)?
            .send()
    }

    func setDivStyle(contextId: BlockId, blockIds: [BlockId], style: BlockDivider.Style) {
        Anytype_Rpc.BlockList.Set.Div.Style.Service
            .invoke(contextID: contextId, blockIds: blockIds, style: style.asMiddleware)
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .blockListService)?
            .send()
    }
    
    func moveTo(contextId: BlockId, blockId: BlockId, targetId: BlockId) {
        Anytype_Rpc.BlockList.Move.Service.invoke(
            contextID: contextId,
            blockIds: [blockId],
            targetContextID: targetId,
            dropTargetID: "",
            position: .bottom
        )
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .blockListService)?
            .send()
    }
}
