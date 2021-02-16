//
//  BlockActionsService+Other+Implementation.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 11.02.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import Foundation
import Combine
import BlocksModels
import ProtobufMessages

fileprivate typealias Namespace = ServiceLayerModule.Other
fileprivate typealias FileNamespace = Namespace.BlockActionsService

/// Concrete service that adopts OtherBlock actions service.
/// NOTE: Use it as default service IF you want to use default functionality.
// MARK: - OtherBlockActionsService

extension Namespace {
    class BlockActionsService: ServiceLayerModule_BlockActionsServiceOtherProtocol {        
        var setDividerStyle: SetDividerStyle = .init()
    }
}

private extension FileNamespace {
    enum PossibleError: Error {
        case setDividerStyleActionStyleConversionHasFailed
    }
}

// MARK: - OtherBlockActionsService / Actions
extension FileNamespace {
    typealias Success = ServiceLayerModule.Success

    /// Structure that adopts `CreatePage` action protocol
    /// NOTE: `CreatePage` action will return block of type `.link(.page)`.
    struct SetDividerStyle: ServiceLayerModule_BlockActionsServiceOtherProtocolSetDividerStyle {
        func action(contextID: BlockId, blockIds: [BlockId], style: Style) -> AnyPublisher<Success, Error> {
            guard let style = BlocksModelsModule.Parser.Other.Divider.Style.Converter.asMiddleware(style) else {
                return Fail.init(error: PossibleError.setDividerStyleActionStyleConversionHasFailed).eraseToAnyPublisher()
            }
            return self.action(contextID: contextID, blockIds: blockIds, style: style)
        }
        private func action(contextID: String, blockIds: [String], style: Anytype_Model_Block.Content.Div.Style) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.BlockList.Set.Div.Style.Service.invoke(contextID: contextID, blockIds: blockIds, style: style).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
        }
    }
}

