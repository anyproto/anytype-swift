//
//  BlockActionsService+Text+Implementation.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 11.02.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import Foundation
import Combine
import UIKit
import ProtobufMessages

fileprivate typealias Namespace = ServiceLayerModule.Text
fileprivate typealias FileNamespace = Namespace.BlockActionsService

private extension Logging.Categories {
    static let service: Self = "BlockActionsService.Text.Implementation"
}

extension Namespace {
    class BlockActionsService: ServiceLayerModule_BlockActionsServiceTextProtocol {
        var setText: SetText = .init()
        var setStyle: SetStyle = .init()
        var setForegroundColor: SetForegroundColor = .init()
        var setAlignment: SetAlignment = .init()
        var split: Split = .init()
        var merge: Merge = .init()
    }
}

private extension FileNamespace {
    enum PossibleError: Error {
        case setStyleActionStyleConversionHasFailed
        case setAlignmentActionAlignmentConversionHasFailed
        case splitActionStyleConversionHasFailed
    }
}

extension FileNamespace {
    typealias Success = ServiceLayerModule.Success
    // MARK: SetText
    struct SetText: ServiceLayerModule_BlockActionsServiceTextProtocolSetText {
        func action(contextID: String, blockID: String, attributedString: NSAttributedString) -> AnyPublisher<Void, Error> {
            // convert attributed string to marks here?
            let result = BlocksModelsModule.Parser.Text.AttributedText.Converter.asMiddleware(attributedText: attributedString)
            return action(contextID: contextID, blockID: blockID, text: result.text, marks: result.marks)
        }
        private func action(contextID: String, blockID: String, text: String, marks: Anytype_Model_Block.Content.Text.Marks) -> AnyPublisher<Void, Error> {
            
            /// TODO: Add private queue, don't use global queue.
            Anytype_Rpc.Block.Set.Text.Text.Service.invoke(contextID: contextID, blockID: blockID, text: text, marks: marks, queue: .global()).successToVoid().subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
        }
    }
    
    // MARK: SetStyle
    struct SetStyle: ServiceLayerModule_BlockActionsServiceTextProtocolSetStyle {
        func action(contextID: BlockId, blockID: BlockId, style: Style) -> AnyPublisher<ServiceLayerModule.Success, Error> {
            guard let style = BlocksModelsModule.Parser.Text.ContentType.Converter.asMiddleware(style) else {
                return Fail.init(error: PossibleError.setStyleActionStyleConversionHasFailed).eraseToAnyPublisher()
            }
            return self.action(contextID: contextID, blockID: blockID, style: style)
        }
        private func action(contextID: String, blockID: String, style: Anytype_Model_Block.Content.Text.Style) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.Block.Set.Text.Style.Service.invoke(contextID: contextID, blockID: blockID, style: style).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
        }
    }
    
    // MARK: SetForegroundColor
    struct SetForegroundColor: ServiceLayerModule_BlockActionsServiceTextProtocolSetForegroundColor {
        func action(contextID: String, blockID: String, color: UIColor) -> AnyPublisher<Void, Error> {
            // convert color to String?
            let result = BlocksModelsModule.Parser.Text.Color.Converter.asMiddleware(color, background: false)
            return action(contextID: contextID, blockID: blockID, color: result)
        }
        private func action(contextID: String, blockID: String, color: String) -> AnyPublisher<Void, Error> {
            Anytype_Rpc.Block.Set.Text.Color.Service.invoke(contextID: contextID, blockID: blockID, color: color)
                .successToVoid().subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
        }
    }
    
    // MARK: SetAlignment
    struct SetAlignment: ServiceLayerModule_BlockActionsServiceTextProtocolSetAlignment {
        func action(contextID: String, blockIds: [String], alignment: NSTextAlignment) -> AnyPublisher<Void, Error> {
            let ourAlignment = BlocksModelsModule.Parser.Common.Alignment.UIKitConverter.asModel(alignment)
            guard let middlewareAlignment = ourAlignment.flatMap(BlocksModelsModule.Parser.Common.Alignment.Converter.asMiddleware) else {
                return Fail.init(error: PossibleError.setAlignmentActionAlignmentConversionHasFailed).eraseToAnyPublisher()
            }
            return self.action(contextID: contextID, blockIds: blockIds, align: middlewareAlignment)
        }

        private func action(contextID: String, blockIds: [String], align: Anytype_Model_Block.Align) -> AnyPublisher<Void, Error> {
            Anytype_Rpc.BlockList.Set.Align.Service.invoke(contextID: contextID, blockIds: blockIds, align: align).successToVoid().subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
        }
    }
    
    // MARK: Split
    struct Split: ServiceLayerModule_BlockActionsServiceTextProtocolSplit {
        func action(contextID: BlockId, blockID: BlockId, range: NSRange, style: Style) -> AnyPublisher<Success, Error> {
            guard let style = BlocksModelsModule.Parser.Text.ContentType.Converter.asMiddleware(style) else {
                return Fail.init(error: PossibleError.splitActionStyleConversionHasFailed).eraseToAnyPublisher()
            }
            let middlewareRange = BlocksModelsModule.Parser.Text.AttributedText.RangeConverter.asMiddleware(range)
            return self.action(contextID: contextID, blockID: blockID, range: middlewareRange, style: style)
        }
        private func action(contextID: String, blockID: String, range: Anytype_Model_Range, style: Anytype_Model_Block.Content.Text.Style) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.Block.Split.Service.invoke(contextID: contextID, blockID: blockID, range: range, style: style, mode: .bottom, queue: .global()).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
        }
    }

    // MARK: Merge
    struct Merge: ServiceLayerModule_BlockActionsServiceTextProtocolMerge {
        func action(contextID: BlockId, firstBlockID: BlockId, secondBlockID: BlockId) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.Block.Merge.Service.invoke(contextID: contextID, firstBlockID: firstBlockID, secondBlockID: secondBlockID, queue: .global())
                .map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
        }
    }
}
