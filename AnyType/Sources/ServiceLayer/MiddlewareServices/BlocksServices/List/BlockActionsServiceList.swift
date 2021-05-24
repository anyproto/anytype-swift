//
//  BlockActionsService+List+Implementation.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 11.02.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import Foundation
import Combine
import BlocksModels
import UIKit
import ProtobufMessages
import SwiftProtobuf


class BlockActionsServiceList: BlockActionsServiceListProtocol {
    var delete: Delete = .init()
    var setFields: SetFields = .init()
    var setTextStyle: SetTextStyle = .init()
    var duplicate: Duplicate = .init()
    var setBackgroundColor: SetBackgroundColor = .init()
    var setAlign: SetAlign = .init()
    var setDivStyle: SetDivStyle = .init()
    var setPageIsArchived: SetPageIsArchived = .init()
    var deletePage: DeletePage = .init()
    
    func setBlockColor(contextID: BlockId, blockIds: [BlockId], color: String) -> AnyPublisher<Success, Error> {
        return Anytype_Rpc.BlockList.Set.Text.Color.Service.invoke(contextID: contextID, blockIds: blockIds, color: color)
            .map(\.event)
            .map(Success.init(_:))
            .subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
    }
}

extension BlockActionsServiceList {
    enum PossibleError: Error {
        case setTextStyleActionStyleConversionHasFailed
        case setAlignActionAlignmentConversionHasFailed
        case setDividerStyleActionStyleConversionHasFailed
    }
}

extension BlockActionsServiceList {
    typealias Success = ServiceSuccess
    
    struct Delete: BlockActionsServiceListProtocolDelete {
        func action(contextID: BlockId, blocksIds: [BlockId]) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.Block.Unlink.Service.invoke(contextID: contextID, blockIds: blocksIds).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
        }
    }
    
    struct SetFields: BlockActionsServiceListProtocolSetFields {
        func action(contextID: BlockId, blockFields: [BlockFields]) -> AnyPublisher<Success, Error> {
            let middleFields = blockFields.map { $0.convertToMiddle() }
            return action(contextID: contextID, blockFields: middleFields)
        }

        private func action(contextID: String, blockFields: [Anytype_Rpc.BlockList.Set.Fields.Request.BlockField]) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.BlockList.Set.Fields.Service.invoke(contextID: contextID, blockFields: blockFields).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
        }
    }

    struct SetTextStyle: BlockActionsServiceListProtocolSetTextStyle {
        func action(contextID: BlockId, blockIds: [BlockId], style: Style) -> AnyPublisher<Success, Error> {
            let style = BlocksModelsParserTextContentTypeConverter.asMiddleware(style)
            return self.action(contextID: contextID, blockIds: blockIds, style: style)
        }
        private func action(contextID: String, blockIds: [String], style: Anytype_Model_Block.Content.Text.Style) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.BlockList.Set.Text.Style.Service.invoke(contextID: contextID, blockIds: blockIds, style: style).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
        }
    }
    /// TODO:
    /// Add implementation.
    ///
    struct Duplicate {
        private func action(contextID: String, targetID: String, blockIds: [String], position: Anytype_Model_Block.Position) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.BlockList.Duplicate.Service.invoke(contextID: contextID, targetID: targetID, blockIds: blockIds, position: position).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
        }
    }

    struct SetBackgroundColor: BlockActionsServiceListProtocolSetBackgroundColor {
        func action(contextID: BlockId, blockIds: [BlockId], color: String) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.BlockList.Set.BackgroundColor.Service.invoke(contextID: contextID,
                                                                     blockIds: blockIds,
                                                                     color: color)
                .map(\.event)
                .map(Success.init(_:))
                .subscribe(on: DispatchQueue.global())
                .eraseToAnyPublisher()
        }
    }

    struct SetAlign: BlockActionsServiceListProtocolSetAlign {
        func action(contextID: BlockId, blockIds: [BlockId], alignment: Alignment) -> AnyPublisher<Success, Error> {
            guard let alignment = BlocksModelsParserCommonAlignmentConverter.asMiddleware(alignment) else {
                return Fail.init(error: PossibleError.setAlignActionAlignmentConversionHasFailed).eraseToAnyPublisher()
            }
            return self.action(contextID: contextID, blockIds: blockIds, align: alignment)
        }

        private func action(contextID: String, blockIds: [String], align: Anytype_Model_Block.Align) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.BlockList.Set.Align.Service.invoke(contextID: contextID, blockIds: blockIds, align: align).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
        }
    }

    struct SetDivStyle: BlockActionsServiceListProtocolSetDivStyle {
        func action(contextID: BlockId, blockIds: [BlockId], style: Style) -> AnyPublisher<Success, Error> {
            guard let style = BlocksModelsParserOtherDividerStyleConverter.asMiddleware(style) else {
                return Fail.init(error: PossibleError.setDividerStyleActionStyleConversionHasFailed).eraseToAnyPublisher()
            }
            return self.action(contextID: contextID, blockIds: blockIds, style: style)
        }
        private func action(contextID: String, blockIds: [String], style: Anytype_Model_Block.Content.Div.Style) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.BlockList.Set.Div.Style.Service.invoke(contextID: contextID, blockIds: blockIds, style: style).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
        }
    }
    struct SetPageIsArchived: BlockActionsServiceListProtocolSetPageIsArchived {
        func action(contextID: BlockId, blockIds: [BlockId], isArchived: Bool) -> AnyPublisher<Success, Error> {
            // TODO: Implement it correctly.
            .empty()
            //            Anytype_Rpc.BlockList.Set.Page.IsArchived.Service.invoke(contextID: contextID, blockIds: blockIds, isArchived: isArchived).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
        }
    }
    struct DeletePage: BlockActionsServiceListProtocolDeletePage {
        func action(blockIds: [String]) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.BlockList.Delete.Page.Service.invoke(blockIds: blockIds).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
        }
    }
}
