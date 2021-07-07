import Foundation
import Combine
import BlocksModels
import UIKit
import ProtobufMessages
import SwiftProtobuf

extension BlockActionsServiceList {
    enum PossibleError: Error {
        case setTextStyleActionStyleConversionHasFailed
        case setAlignActionAlignmentConversionHasFailed
        case setDividerStyleActionStyleConversionHasFailed
    }
}

class BlockActionsServiceList: BlockActionsServiceListProtocol {
    func setBlockColor(contextID: BlockId, blockIds: [BlockId], color: String) -> AnyPublisher<ServiceSuccess, Error> {
        return Anytype_Rpc.BlockList.Set.Text.Color.Service.invoke(contextID: contextID, blockIds: blockIds, color: color)
            .map(\.event)
            .map(ServiceSuccess.init(_:))
            .subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
    }
    
    func delete(contextID: BlockId, blocksIds: [BlockId]) -> AnyPublisher<ServiceSuccess, Error> {
        Anytype_Rpc.Block.Unlink.Service.invoke(contextID: contextID, blockIds: blocksIds).map(\.event).map(ServiceSuccess.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
    }
    
    func setFields(contextID: BlockId, blockFields: [BlockFields]) -> AnyPublisher<ServiceSuccess, Error> {
        let middleFields = blockFields.map { $0.convertToMiddle() }
        return setFields(contextID: contextID, blockFields: middleFields)
    }

    private func setFields(contextID: String, blockFields: [Anytype_Rpc.BlockList.Set.Fields.Request.BlockField]) -> AnyPublisher<ServiceSuccess, Error> {
        Anytype_Rpc.BlockList.Set.Fields.Service.invoke(contextID: contextID, blockFields: blockFields).map(\.event).map(ServiceSuccess.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
    }

    func setTextStyle(contextID: BlockId, blockIds: [BlockId], style: TextStyle) -> AnyPublisher<ServiceSuccess, Error> {
        let style = BlockTextContentTypeConverter.asMiddleware(style)
        return setTextStyle(contextID: contextID, blockIds: blockIds, style: style)
    }
    private func setTextStyle(contextID: String, blockIds: [String], style: Anytype_Model_Block.Content.Text.Style) -> AnyPublisher<ServiceSuccess, Error> {
        Anytype_Rpc.BlockList.Set.Text.Style.Service.invoke(contextID: contextID, blockIds: blockIds, style: style).map(\.event).map(ServiceSuccess.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
    }

    func setBackgroundColor(contextID: BlockId, blockIds: [BlockId], color: String) -> AnyPublisher<ServiceSuccess, Error> {
        Anytype_Rpc.BlockList.Set.BackgroundColor.Service.invoke(contextID: contextID, blockIds: blockIds, color: color)
            .map(\.event)
            .map(ServiceSuccess.init(_:))
            .subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
    }

    func setAlign(contextID: BlockId, blockIds: [BlockId], alignment: Alignment) -> AnyPublisher<ServiceSuccess, Error> {
        guard let alignment = BlocksModelsParserCommonAlignmentConverter.asMiddleware(alignment) else {
            return Fail.init(error: PossibleError.setAlignActionAlignmentConversionHasFailed).eraseToAnyPublisher()
        }
        return setAlign(contextID: contextID, blockIds: blockIds, align: alignment)
    }

    private func setAlign(contextID: String, blockIds: [String], align: Anytype_Model_Block.Align) -> AnyPublisher<ServiceSuccess, Error> {
        Anytype_Rpc.BlockList.Set.Align.Service.invoke(contextID: contextID, blockIds: blockIds, align: align).map(\.event).map(ServiceSuccess.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
    }

    func setDivStyle(contextID: BlockId, blockIds: [BlockId], style: DividerStyle) -> AnyPublisher<ServiceSuccess, Error> {
        let style = BlocksModelsParserOtherDividerStyleConverter.asMiddleware(style)
        return setDivStyle(contextID: contextID, blockIds: blockIds, style: style)
    }
    private func setDivStyle(contextID: String, blockIds: [String], style: Anytype_Model_Block.Content.Div.Style) -> AnyPublisher<ServiceSuccess, Error> {
        Anytype_Rpc.BlockList.Set.Div.Style.Service.invoke(contextID: contextID, blockIds: blockIds, style: style).map(\.event).map(ServiceSuccess.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
    }
    
    func setPageIsArchived(contextID: BlockId, blockIds: [BlockId], isArchived: Bool) -> AnyPublisher<ServiceSuccess, Error> {
        assertionFailure("Not implemented: setPageIsArchived")
        // TODO: Implement it correctly.
        return .empty()
        //            Anytype_Rpc.BlockList.Set.Page.IsArchived.Service.invoke(contextID: contextID, blockIds: blockIds, isArchived: isArchived).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
    }
    
    func delete(blockIds: [String]) -> AnyPublisher<ServiceSuccess, Error> {
        Anytype_Rpc.BlockList.Delete.Page.Service.invoke(blockIds: blockIds).map(\.event).map(ServiceSuccess.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
    }
}
