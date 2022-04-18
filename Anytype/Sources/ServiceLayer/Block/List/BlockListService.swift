import Foundation
import Combine
import BlocksModels
import UIKit
import ProtobufMessages
import SwiftProtobuf
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
    
    func setFields(fields: [Anytype_Rpc.BlockList.Set.Fields.Request.BlockField]) {
        Anytype_Rpc.BlockList.Set.Fields.Service
            .invoke(contextID: contextId, blockFields: fields)
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .blockListService)?
            .send()
    }

    func setBackgroundColor(blockIds: [BlockId], color: MiddlewareColor) {
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.blockListSetBackgroundColor)

        Anytype_Rpc.BlockList.Set.BackgroundColor.Service
            .invoke(contextID: contextId, blockIds: blockIds, color: color.rawValue)
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .blockListService)?
            .send()
    }

    func setAlign(blockIds: [BlockId], alignment: LayoutAlignment) {
        AnytypeAnalytics.instance().logSetAlignment(alignment, isBlock: blockIds.isNotEmpty)

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
    
    func move(blockId: BlockId, targetId: BlockId, position: Anytype_Model_Block.Position) {
        Anytype_Rpc.BlockList.Move.Service.invoke(
            contextID: contextId,
            blockIds: [blockId],
            targetContextID: contextId,
            dropTargetID: targetId,
            position: position
        )
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .blockListService)?
            .send()
    }
    
    func moveToPage(blockId: BlockId, pageId: BlockId) {
        Anytype_Rpc.BlockList.Move.Service.invoke(
            contextID: contextId,
            blockIds: [blockId],
            targetContextID: pageId,
            dropTargetID: "",
            position: .bottom
        )
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .blockListService)?
            .send()
    }
}
