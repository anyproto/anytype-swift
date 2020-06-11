//
//  BlocksModels+Parser+Details.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 04.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftProtobuf
import Combine
import os

private extension Logging.Categories {
    static let blocksModelParserDetails: Self = "BlocksModels.Parser.Details"
}

// MARK: Details
extension BlocksModels.Parser {
    enum Details {}
}

// MARK: Protocols
protocol BlocksModelsParserDetailsConverterProtocol {
    associatedtype Model
    static func asMiddleware(model: Model) -> Anytype_Rpc.Block.Set.Details.Detail?
    static func asModel(detail: Anytype_Rpc.Block.Set.Details.Detail) -> Model?
}

extension BlocksModelsParserDetailsConverterProtocol {
    static func asMiddleware(models: [Model]) -> [Anytype_Rpc.Block.Set.Details.Detail] {
        models.compactMap(self.asMiddleware)
    }
    static func asModel(details: [Anytype_Rpc.Block.Set.Details.Detail]) -> [Model] {
        details.compactMap(self.asModel)
    }
}

// MARK: Details / Converter
extension BlocksModels.Parser.Details {
    /// Top converter which convert all details to and from protobuf.
    ///
    enum Converter: BlocksModelsParserDetailsConverterProtocol {
        
        typealias Model = BlocksModels.Block.Information.Details
        static func asMiddleware(model: Model) -> Anytype_Rpc.Block.Set.Details.Detail? {
            switch model {
            case let .title(title): return Model.Title.Converter.asMiddleware(model: title)
            case let .iconEmoji(emoji): return Model.Emoji.Converter.asMiddleware(model: emoji)
            }
        }

        // We can't put into one array all converters. But we doesn't care, haha.
        static func asModel(detail: Anytype_Rpc.Block.Set.Details.Detail) -> Model? {
            switch detail.key {
            case Model.Title.id: return Model.Title.Converter.asModel(detail: detail).flatMap(Model.title)
            case Model.Emoji.id: return Model.Emoji.Converter.asModel(detail: detail).flatMap(Model.iconEmoji)
            default:
                let logger = Logging.createLogger(category: .blocksModelParserDetails)
                os_log(.debug, log: logger, "Add converters for this type: (%@) ", detail.key)

                return nil
            }
        }
    }
}

// MARK: Details / Title / Accessors
private extension BlocksModels.Block.Information.Details.Title {
    func key() -> String { id }
    func value() -> Google_Protobuf_Value { .init(stringValue: text) }
}

// MARK: Details / Title / Converter
private extension BlocksModels.Block.Information.Details.Title {
    enum Converter: BlocksModelsParserDetailsConverterProtocol {
        typealias Model = BlocksModels.Block.Information.Details.Title
        static func asMiddleware(model: Model) -> Anytype_Rpc.Block.Set.Details.Detail? {
            .init(key: model.key(), value: model.value())
        }
        static func asModel(detail: Anytype_Rpc.Block.Set.Details.Detail) -> Model? {
            guard detail.key == Model.id else {
                let logger = Logging.createLogger(category: .blocksModelParserDetails)
                os_log(.debug, log: logger, "Can't proceed detail with key (%@) for predefined suffix. (%@)", detail.key, Model.id)
                return nil
            }
            switch detail.value.kind {
                case let .stringValue(string): return .init(text: string)
                default:
                    let logger = Logging.createLogger(category: .blocksModelParserDetails)
                    os_log(.debug, log: logger, "Unknown value (%@) for predefined suffix. %@", String(describing: detail), Model.id)
                    return nil
            }
        }
    }
}

// MARK: Details / Emoji / Converter
private extension BlocksModels.Block.Information.Details.Emoji {
    enum Converter: BlocksModelsParserDetailsConverterProtocol {
        typealias Model = BlocksModels.Block.Information.Details.Emoji
        static func asMiddleware(model: Model) -> Anytype_Rpc.Block.Set.Details.Detail? {
            .init(key: model.key(), value: model.value())
        }
        static func asModel(detail: Anytype_Rpc.Block.Set.Details.Detail) -> Model? {
            guard detail.key == Model.id else {
                let logger = Logging.createLogger(category: .blocksModelParserDetails)
                os_log(.debug, log: logger, "Can't proceed detail with key (%@) for predefined suffix. (%@)", detail.key, Model.id)
                return nil
            }
            switch detail.value.kind {
                case let .stringValue(string): return .init(text: string)
                default:
                    let logger = Logging.createLogger(category: .blocksModelParserDetails)
                    os_log(.debug, log: logger, "Unknown value (%@) for predefined suffix. %@", String(describing: detail), Model.id)
                    return nil
            }
        }
    }
}

// MARK: Details / Emoji / Accessors
private extension BlocksModels.Block.Information.Details.Emoji {
    func key() -> String { id }
    func value() -> Google_Protobuf_Value { .init(stringValue: text) }
}
