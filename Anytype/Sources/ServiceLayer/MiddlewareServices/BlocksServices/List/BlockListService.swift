import Foundation
import Combine
import BlocksModels
import UIKit
import ProtobufMessages
import SwiftProtobuf
import Amplitude
import AnytypeCore

class BlockListService: BlockListServiceProtocol {
    func setBlockColor(contextId: BlockId, blockIds: [BlockId], color: MiddlewareColor) -> ResponseEvent? {
        Anytype_Rpc.BlockList.Set.Text.Color.Service
            .invoke(contextID: contextId, blockIds: blockIds, color: color.rawValue)
            .map { ResponseEvent($0.event) }
            .getValue()
    }
    
    func setFields(contextId: BlockId, fields: [BlockFields]) -> ResponseEvent? {
        let middleFields = fields .map { $0.convertToMiddle() }
        return Anytype_Rpc.BlockList.Set.Fields.Service
            .invoke(contextID: contextId, blockFields: middleFields)
            .map { ResponseEvent($0.event) }
            .getValue()
    }

    func setTextStyle(contextId: BlockId, blockIds: [BlockId], style: BlockText.Style) -> AnyPublisher<ResponseEvent, Error> {
        Anytype_Rpc.BlockList.Set.Text.Style.Service
            .invoke(contextID: contextId, blockIds: blockIds, style: style.asMiddleware)
            .map(\.event)
            .map(ResponseEvent.init(_:))
            .subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
    }

    func setBackgroundColor(contextId: BlockId, blockIds: [BlockId], color: MiddlewareColor) -> ResponseEvent? {
        Amplitude.instance().logEvent(AmplitudeEventsName.blockListSetBackgroundColor)
        return Anytype_Rpc.BlockList.Set.BackgroundColor.Service.invoke(contextID: contextId, blockIds: blockIds, color: color.rawValue)
            .map { ResponseEvent($0.event) }
            .getValue()
    }

    func setAlign(contextId: BlockId, blockIds: [BlockId], alignment: LayoutAlignment) -> ResponseEvent? {
        Amplitude.instance().logEvent(AmplitudeEventsName.blockListSetAlign)
        return Anytype_Rpc.BlockList.Set.Align.Service
            .invoke(contextID: contextId, blockIds: blockIds, align: alignment.asMiddleware)
            .map { ResponseEvent($0.event) }
            .getValue()
    }

    func setDivStyle(contextId: BlockId, blockIds: [BlockId], style: BlockDivider.Style) -> ResponseEvent? {
        Amplitude.instance().logEvent(AmplitudeEventsName.blockListSetDivStyle)
        return Anytype_Rpc.BlockList.Set.Div.Style.Service
            .invoke(contextID: contextId, blockIds: blockIds, style: style.asMiddleware)
            .map { ResponseEvent($0.event) }
            .getValue()
    }
    
    func delete(blockIds: [String]) -> ResponseEvent? {
        Anytype_Rpc.BlockList.Delete.Page.Service.invoke(blockIds: blockIds)
            .map { ResponseEvent($0.event) }
            .getValue()
    }
    
    func moveTo(contextId: BlockId, blockId: BlockId, targetId: BlockId) -> ResponseEvent? {
        Anytype_Rpc.BlockList.Move.Service.invoke(
            contextID: contextId,
            blockIds: [blockId],
            targetContextID: targetId,
            dropTargetID: "",
            position: .bottom
        )
            .map { ResponseEvent($0.event) }
            .getValue()
    }
}
