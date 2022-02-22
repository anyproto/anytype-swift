import Foundation
import Combine
import BlocksModels
import UIKit
import ProtobufMessages
import SwiftProtobuf
import Amplitude
import AnytypeCore

class BlockListService: BlockListServiceProtocol {
    private let contextId: BlockId
    init(contextId: BlockId) {
        self.contextId = contextId
    }
    
    func setBlockColor(blockIds: [BlockId], color: MiddlewareColor) {
        Anytype_Rpc.BlockList.Set.Text.Color.Service
            .invoke(contextID: contextId, blockIds: blockIds, color: color.rawValue)
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .blockListService)?
            .send()
    }
    
    func setFields(fields: [BlockFields]) {
        let middleFields = fields.map { $0.convertToMiddle() }
        Anytype_Rpc.BlockList.Set.Fields.Service
            .invoke(contextID: contextId, blockFields: middleFields)
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .blockListService)?
            .send()
    }

    func setBackgroundColor(blockIds: [BlockId], color: MiddlewareColor) {
        Amplitude.instance().logEvent(AmplitudeEventsName.blockListSetBackgroundColor)

        Anytype_Rpc.BlockList.Set.BackgroundColor.Service
            .invoke(contextID: contextId, blockIds: blockIds, color: color.rawValue)
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .blockListService)?
            .send()
    }

    func setAlign(blockIds: [BlockId], alignment: LayoutAlignment) {
        Amplitude.instance().logSetAlignment(alignment, isBlock: blockIds.isNotEmpty)

        Anytype_Rpc.BlockList.Set.Align.Service
            .invoke(contextID: contextId, blockIds: blockIds, align: alignment.asMiddleware)
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .blockListService)?
            .send()
    }

    func setDivStyle(blockIds: [BlockId], style: BlockDivider.Style) {
        Anytype_Rpc.BlockList.Set.Div.Style.Service
            .invoke(contextID: contextId, blockIds: blockIds, style: style.asMiddleware)
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .blockListService)?
            .send()
    }

    func replace(blockIds: [BlockId], targetId: BlockId) {
        Anytype_Rpc.BlockList.Move.Service.invoke(
            contextID: contextId,
            blockIds: blockIds,
            targetContextID: contextId,
            dropTargetID: targetId,
            position: .replace
        )
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .blockListService)?
            .send()
    }
    
    func moveTo(blockId: BlockId, targetId: BlockId) {
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
