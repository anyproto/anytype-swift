import Foundation
import Combine
import BlocksModels
import UIKit
import ProtobufMessages
import SwiftProtobuf
import Amplitude
import AnytypeCore

extension BlockActionsServiceList {
    enum PossibleError: Error {
        case setTextStyleActionStyleConversionHasFailed
        case setDividerStyleActionStyleConversionHasFailed
    }
}

class BlockActionsServiceList: BlockActionsServiceListProtocol {
    func setBlockColor(contextID: BlockId, blockIds: [BlockId], color: MiddlewareColor) -> AnyPublisher<ResponseEvent, Error> {
        return Anytype_Rpc.BlockList.Set.Text.Color.Service.invoke(contextID: contextID, blockIds: blockIds, color: color.rawValue)
            .map(\.event)
            .map(ResponseEvent.init(_:))
            .subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
    }
    
    func setFields(contextID: BlockId, blockFields: [BlockFields]) -> AnyPublisher<ResponseEvent, Error> {
        let middleFields = blockFields.map { $0.convertToMiddle() }
        return setFields(contextID: contextID, blockFields: middleFields)
    }

    private func setFields(contextID: String, blockFields: [Anytype_Rpc.BlockList.Set.Fields.Request.BlockField]) -> AnyPublisher<ResponseEvent, Error> {
        Anytype_Rpc.BlockList.Set.Fields.Service.invoke(contextID: contextID, blockFields: blockFields).map(\.event).map(ResponseEvent.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
    }

    func setTextStyle(contextID: BlockId, blockIds: [BlockId], style: TextStyle) -> AnyPublisher<ResponseEvent, Error> {
        let style = BlockTextContentTypeConverter.asMiddleware(style)
        return setTextStyle(contextID: contextID, blockIds: blockIds, style: style)
    }
    private func setTextStyle(contextID: String, blockIds: [String], style: Anytype_Model_Block.Content.Text.Style) -> AnyPublisher<ResponseEvent, Error> {
        Anytype_Rpc.BlockList.Set.Text.Style.Service.invoke(contextID: contextID, blockIds: blockIds, style: style).map(\.event).map(ResponseEvent.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
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

    func setAlign(contextID: BlockId, blockIds: [BlockId], alignment: Alignment) -> AnyPublisher<ResponseEvent, Error> {
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

    func setDivStyle(contextID: BlockId, blockIds: [BlockId], style: DividerStyle) -> AnyPublisher<ResponseEvent, Error> {
        let style = BlocksModelsParserOtherDividerStyleConverter.asMiddleware(style)
        return setDivStyle(contextID: contextID, blockIds: blockIds, style: style)
    }

    private func setDivStyle(contextID: String, blockIds: [String], style: Anytype_Model_Block.Content.Div.Style) -> AnyPublisher<ResponseEvent, Error> {
        Anytype_Rpc.BlockList.Set.Div.Style.Service.invoke(contextID: contextID, blockIds: blockIds, style: style).map(\.event).map(ResponseEvent.init(_:)).subscribe(on: DispatchQueue.global())
            .handleEvents(receiveRequest:  {_ in
                // Analytics
                Amplitude.instance().logEvent(AmplitudeEventsName.blockListSetDivStyle)
            })
            .eraseToAnyPublisher()
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
