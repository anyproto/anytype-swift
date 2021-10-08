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

    func setTextStyle(contextID: BlockId, blockIds: [BlockId], style: BlockText.Style) -> AnyPublisher<ResponseEvent, Error> {
        Anytype_Rpc.BlockList.Set.Text.Style.Service
            .invoke(contextID: contextID, blockIds: blockIds, style: style.asMiddleware)
            .map(\.event)
            .map(ResponseEvent.init(_:))
            .subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
    }

    func setBackgroundColor(contextID: BlockId, blockIds: [BlockId], color: MiddlewareColor) -> AnyPublisher<ResponseEvent, Error> {
        Anytype_Rpc.BlockList.Set.BackgroundColor.Service.invoke(contextID: contextID, blockIds: blockIds, color: color.rawValue)
            .map(\.event)
            .map(ResponseEvent.init(_:))
            .subscribe(on: DispatchQueue.global())
            .handleEvents(receiveRequest:  {_ in
                // Analytics
                Amplitude.instance().logEvent(AmplitudeEventsName.blockListSetBackgroundColor)
            })
            .eraseToAnyPublisher()
    }

    func setAlign(contextID: BlockId, blockIds: [BlockId], alignment: LayoutAlignment) -> AnyPublisher<ResponseEvent, Error> {
        return setAlign(contextID: contextID, blockIds: blockIds, align: alignment.asMiddleware)
    }

    private func setAlign(contextID: String, blockIds: [String], align: Anytype_Model_Block.Align) -> AnyPublisher<ResponseEvent, Error> {
        Anytype_Rpc.BlockList.Set.Align.Service.invoke(contextID: contextID, blockIds: blockIds, align: align).map(\.event).map(ResponseEvent.init(_:)).subscribe(on: DispatchQueue.global())
            .handleEvents(receiveRequest:  {_ in
                // Analytics
                Amplitude.instance().logEvent(AmplitudeEventsName.blockListSetAlign)
            })
            .eraseToAnyPublisher()
    }

    func setDivStyle(contextId: BlockId, blockIds: [BlockId], style: BlockDivider.Style) -> ResponseEvent? {
        Amplitude.instance().logEvent(AmplitudeEventsName.blockListSetDivStyle)
        return Anytype_Rpc.BlockList.Set.Div.Style.Service
            .invoke(contextID: contextId, blockIds: blockIds, style: style.asMiddleware)
            .map { ResponseEvent($0.event) }
            .getValue()
    }
    
    func setPageIsArchived(contextID: BlockId, blockIds: [BlockId], isArchived: Bool) -> AnyPublisher<ResponseEvent, Error> {
        anytypeAssertionFailure("Not implemented: setPageIsArchived")
        // TODO: Implement it correctly.
        return .empty()
        //            Anytype_Rpc.BlockList.Set.Page.IsArchived.Service.invoke(contextID: contextID, blockIds: blockIds, isArchived: isArchived).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
    }
    
    func delete(blockIds: [String]) -> AnyPublisher<ResponseEvent, Error> {
        Anytype_Rpc.BlockList.Delete.Page.Service.invoke(blockIds: blockIds).map(\.event).map(ResponseEvent.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
    }
    
    func moveTo(contextId: BlockId, blockId: BlockId, targetId: BlockId) -> ResponseEvent? {
        let result = Anytype_Rpc.BlockList.Move.Service.invoke(
            contextID: contextId,
            blockIds: [blockId],
            targetContextID: targetId,
            dropTargetID: "",
            position: .bottom
        )
        
        return (try? result.get()).flatMap { ResponseEvent($0.event) }
    }
}
