import Foundation
import Combine
import UIKit
import ProtobufMessages
import BlocksModels
import Amplitude


private extension BlockActionsServiceText {
    enum PossibleError: Error {
        case setStyleActionStyleConversionHasFailed
        case setAlignmentActionAlignmentConversionHasFailed
        case splitActionStyleConversionHasFailed
    }
}

final class BlockActionsServiceText: BlockActionsServiceTextProtocol {    

    @discardableResult
    func setText(contextId: String, blockId: String, middlewareString: MiddlewareString) -> ResponseEvent? {
        let result = Anytype_Rpc.Block.Set.Text.Text.Service
            .invoke(contextID: contextId, blockID: blockId, text: middlewareString.text, marks: middlewareString.marks)
            .map { ResponseEvent($0.event) }
            .getValue()
        
        Amplitude.instance().logEvent(AmplitudeEventsName.blockSetTextText)
        return result
    }
    
    // MARK: SetStyle
    func setStyle(contextID: BlockId, blockID: BlockId, style: Style) -> AnyPublisher<ResponseEvent, Error> {
        Anytype_Rpc.Block.Set.Text.Style.Service
            .invoke(contextID: contextID, blockID: blockID, style: style.asMiddleware)
            .map(\.event)
            .map(ResponseEvent.init(_:))
            .subscribe(on: DispatchQueue.global())
            .receiveOnMain()
            .handleEvents(receiveSubscription: { _ in
                // Analytics
                Amplitude.instance().logEvent(
                    AmplitudeEventsName.blockSetTextStyle,
                    withEventProperties: [AmplitudeEventsPropertiesKey.blockStyle: String(describing: style)]
                )
            })
            .eraseToAnyPublisher()
    }
    
    // MARK: SetForegroundColor
    func setForegroundColor(contextID: String, blockID: String, color: String) -> AnyPublisher<Void, Error> {
        Anytype_Rpc.Block.Set.Text.Color.Service.invoke(contextID: contextID, blockID: blockID, color: color)
            .successToVoid()
            .subscribe(on: DispatchQueue.global())
            .receiveOnMain()
            .eraseToAnyPublisher()
    }
    
    func split(
        contextId: BlockId,
        blockId: BlockId, range: NSRange,
        style: Style,
        mode: Anytype_Rpc.Block.Split.Request.Mode
    ) -> SplitSuccess? {
        let middlewareRange = RangeConverter.asMiddleware(range)

        let success = Anytype_Rpc.Block.Split.Service.invoke(
            contextID: contextId, blockID: blockId, range: middlewareRange, style: style.asMiddleware, mode: mode)
            .map { SplitSuccess($0) }
            .getValue()
        
        Amplitude.instance().logEvent(AmplitudeEventsName.blockSplit)
        return success
    }

    // MARK: Merge
    func merge(contextID: BlockId, firstBlockID: BlockId, secondBlockID: BlockId) -> AnyPublisher<ResponseEvent, Error> {
        Anytype_Rpc.Block.Merge.Service.invoke(
            contextID: contextID, firstBlockID: firstBlockID, secondBlockID: secondBlockID, queue: .global()
        )    
        .map(\.event).map(ResponseEvent.init(_:)).subscribe(on: DispatchQueue.global())
        .receiveOnMain()
        .handleEvents(receiveSubscription: { _ in
            // Analytics
            Amplitude.instance().logEvent(AmplitudeEventsName.blockMerge)
        })
        .eraseToAnyPublisher()
    }
    
    // MARK: Checked
    func checked(contextId: BlockId, blockId: BlockId, newValue: Bool) -> AnyPublisher<ResponseEvent, Error> {
        Anytype_Rpc.Block.Set.Text.Checked.Service.invoke(
            contextID: contextId,
            blockID: blockId,
            checked: newValue,
            queue: .global()
        )
        .map(\.event)
        .map(ResponseEvent.init(_:))
        .subscribe(on: DispatchQueue.global())
        .receiveOnMain()
        .handleEvents(receiveSubscription: { _ in
            // Analytics
            Amplitude.instance().logEvent(AmplitudeEventsName.blockSetTextChecked)
        })
        .eraseToAnyPublisher()
    }
    
}
