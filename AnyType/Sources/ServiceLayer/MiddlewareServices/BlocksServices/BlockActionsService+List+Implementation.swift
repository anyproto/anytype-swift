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

fileprivate typealias Namespace = ServiceLayerModule.List
fileprivate typealias FileNamespace = Namespace.BlockActionsService

extension Namespace {
    class BlockActionsService: ServiceLayerModule_BlockActionsServiceListProtocol {
        var delete: Delete = .init()
        var setFields: SetFields = .init()
        var setTextStyle: SetTextStyle = .init()
        var duplicate: Duplicate = .init()
        var setBackgroundColor: SetBackgroundColor = .init()
        var setAlign: SetAlign = .init()
        var setDivStyle: SetDivStyle = .init()
        var setPageIsArchived: SetPageIsArchived = .init()
        var deletePage: DeletePage = .init()
        
        func setBlockColor(contextID: BlockId, blockIds: [BlockId], color: UIColor?) -> AnyPublisher<Success, Error> {
            let colorAsString = BlocksModelsModule.Parser.Text.Color.Converter.asMiddleware(color, background: false)
            return Anytype_Rpc.BlockList.Set.Text.Color.Service.invoke(contextID: contextID, blockIds: blockIds, color: colorAsString)
                .map(\.event)
                .map(Success.init(_:))
                .subscribe(on: DispatchQueue.global())
                .eraseToAnyPublisher()
        }
    }
}

extension FileNamespace {
    enum PossibleError: Error {
        case setTextStyleActionStyleConversionHasFailed
        case setAlignActionAlignmentConversionHasFailed
        case setDividerStyleActionStyleConversionHasFailed
    }
}

extension FileNamespace {
    typealias Success = ServiceLayerModule.Success
    
    struct Delete: ServiceLayerModule_BlockActionsServiceListProtocolDelete {
        func action(contextID: BlockId, blocksIds: [BlockId]) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.Block.Unlink.Service.invoke(contextID: contextID, blockIds: blocksIds).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
        }
    }
    
    struct SetFields: ServiceLayerModule_BlockActionsServiceListProtocolSetFields {
        /// TODO: Add conversion from our fields to middleware fields
        func action(contextID: BlockId, blockFields: [String]) -> AnyPublisher<Success, Error> {
            self.action(contextID: contextID, blockFields: [Anytype_Rpc.BlockList.Set.Fields.Request.BlockField]())
        }
        private func action(contextID: String, blockFields: [Anytype_Rpc.BlockList.Set.Fields.Request.BlockField]) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.BlockList.Set.Fields.Service.invoke(contextID: contextID, blockFields: blockFields).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
        }
    }
    struct SetTextStyle: ServiceLayerModule_BlockActionsServiceListProtocolSetTextStyle {
        func action(contextID: BlockId, blockIds: [BlockId], style: Style) -> AnyPublisher<Success, Error> {
            guard let style = BlocksModelsModule.Parser.Text.ContentType.Converter.asMiddleware(style) else {
                return Fail.init(error: PossibleError.setTextStyleActionStyleConversionHasFailed).eraseToAnyPublisher()
            }
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
    struct SetBackgroundColor: ServiceLayerModule_BlockActionsServiceListProtocolSetBackgroundColor {
        func action(contextID: BlockId, blockIds: [BlockId], color: UIColor?) -> AnyPublisher<Success, Error> {
            // convert color to String?
            let result = BlocksModelsModule.Parser.Text.Color.Converter.asMiddleware(color, background: true)
            return action(contextID: contextID, blockIds: blockIds, color: result)
        }
        private func action(contextID: String, blockIds: [String], color: String) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.BlockList.Set.BackgroundColor.Service.invoke(contextID: contextID, blockIds: blockIds, color: color).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
        }
    }

    struct SetAlign: ServiceLayerModule_BlockActionsServiceListProtocolSetAlign {
        func action(contextID: BlockId, blockIds: [BlockId], alignment: Alignment) -> AnyPublisher<Success, Error> {
            guard let alignment = BlocksModelsModule.Parser.Common.Alignment.Converter.asMiddleware(alignment) else {
                return Fail.init(error: PossibleError.setAlignActionAlignmentConversionHasFailed).eraseToAnyPublisher()
            }
            return self.action(contextID: contextID, blockIds: blockIds, align: alignment)
        }

        private func action(contextID: String, blockIds: [String], align: Anytype_Model_Block.Align) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.BlockList.Set.Align.Service.invoke(contextID: contextID, blockIds: blockIds, align: align).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
        }
    }

    struct SetDivStyle: ServiceLayerModule_BlockActionsServiceListProtocolSetDivStyle {
        func action(contextID: BlockId, blockIds: [BlockId], style: Style) -> AnyPublisher<Success, Error> {
            guard let style = BlocksModelsModule.Parser.Other.Divider.Style.Converter.asMiddleware(style) else {
                return Fail.init(error: PossibleError.setDividerStyleActionStyleConversionHasFailed).eraseToAnyPublisher()
            }
            return self.action(contextID: contextID, blockIds: blockIds, style: style)
        }
        private func action(contextID: String, blockIds: [String], style: Anytype_Model_Block.Content.Div.Style) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.BlockList.Set.Div.Style.Service.invoke(contextID: contextID, blockIds: blockIds, style: style).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
        }
    }
    struct SetPageIsArchived: ServiceLayerModule_BlockActionsServiceListProtocolSetPageIsArchived {
        func action(contextID: BlockId, blockIds: [BlockId], isArchived: Bool) -> AnyPublisher<Success, Error> {
            // TODO: Implement it correctly.
            .empty()
            //            Anytype_Rpc.BlockList.Set.Page.IsArchived.Service.invoke(contextID: contextID, blockIds: blockIds, isArchived: isArchived).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
        }
    }
    struct DeletePage: ServiceLayerModule_BlockActionsServiceListProtocolDeletePage {
        func action(blockIds: [String]) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.BlockList.Delete.Page.Service.invoke(blockIds: blockIds).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
        }
    }
}
