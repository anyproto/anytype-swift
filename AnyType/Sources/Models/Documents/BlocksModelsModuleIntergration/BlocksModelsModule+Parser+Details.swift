//
//  BlocksModelsModule+Parser+Details.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 13.07.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftProtobuf
import ProtobufMessages
import Combine
import os
import BlocksModels

fileprivate typealias Namespace = BlocksModelsModule.Parser
fileprivate typealias ModelsNamespace = TopLevel.AliasesMap.DetailsContent
private extension Logging.Categories {
    static let blocksModelsModuleParserDetails: Self = "BlocksModelsModule.Parser.Details"
}

// MARK: Details
extension Namespace {
    enum Details {}
}

// MARK: Protocols
protocol _BlocksModelsParserDetailsConverterProtocol {
    associatedtype Model
    static func asMiddleware(model: Model) -> Anytype_Rpc.Block.Set.Details.Detail?
    static func asModel(detail: Anytype_Rpc.Block.Set.Details.Detail) -> Model?
}

extension _BlocksModelsParserDetailsConverterProtocol {
    static func asMiddleware(models: [Model]) -> [Anytype_Rpc.Block.Set.Details.Detail] {
        models.compactMap(self.asMiddleware)
    }
    static func asModel(details: [Anytype_Rpc.Block.Set.Details.Detail]) -> [Model] {
        details.compactMap(self.asModel)
    }
}

// MARK: Details / Converter
extension Namespace.Details {
    /// Top converter which convert all details to and from protobuf.
    ///
    enum Converter: _BlocksModelsParserDetailsConverterProtocol {
        
        typealias Model = TopLevel.AliasesMap.DetailsContent
        static func asMiddleware(model: Model) -> Anytype_Rpc.Block.Set.Details.Detail? {
            switch model {
            case let .title(value): return Model.Title.Converter.asMiddleware(model: value)
            case let .iconEmoji(value): return Model.Emoji.Converter.asMiddleware(model: value)
            case let .iconColor(value): return Model.OurHexColor.Converter.asMiddleware(model: value)
            case let .iconImage(value): return Model.ImageId.Converter.asMiddleware(model: value)
            }
        }

        // We can't put into one array all converters. But we doesn't care, haha.
        static func asModel(detail: Anytype_Rpc.Block.Set.Details.Detail) -> Model? {
            switch detail.key {
            case Model.Title.id: return Model.Title.Converter.asModel(detail: detail).flatMap(Model.title)
            case Model.Emoji.id: return Model.Emoji.Converter.asModel(detail: detail).flatMap(Model.iconEmoji)
            case Model.OurHexColor.id: return Model.OurHexColor.Converter.asModel(detail: detail).flatMap(Model.iconColor)
            case Model.ImageId.id: return Model.ImageId.Converter.asModel(detail: detail).flatMap(Model.iconImage)
            default:
                let logger = Logging.createLogger(category: .blocksModelsModuleParserDetails)
                os_log(.debug, log: logger, "Add converters for this type: (%@) ", detail.key)

                return nil
            }
        }
    }
}

// MARK: Details / Title / Accessors
private extension ModelsNamespace.Title {
    func key() -> String { id }
    func value() -> Google_Protobuf_Value { .init(stringValue: self.value) }
}

// MARK: Details / Title / Converter
private extension ModelsNamespace.Title {
    enum Converter: _BlocksModelsParserDetailsConverterProtocol {
        typealias Model = TopLevel.AliasesMap.DetailsContent.Title
        static func asMiddleware(model: Model) -> Anytype_Rpc.Block.Set.Details.Detail? {
            .init(key: model.key(), value: model.value())
        }
        static func asModel(detail: Anytype_Rpc.Block.Set.Details.Detail) -> Model? {
            guard detail.key == Model.id else {
                let logger = Logging.createLogger(category: .blocksModelsModuleParserDetails)
                os_log(.debug, log: logger, "Can't proceed detail with key (%@) for predefined suffix. (%@)", detail.key, Model.id)
                return nil
            }
            switch detail.value.kind {
                case let .stringValue(string): return .init(value: string)
                default:
                    let logger = Logging.createLogger(category: .blocksModelsModuleParserDetails)
                    os_log(.debug, log: logger, "Unknown value (%@) for predefined suffix. %@", String(describing: detail), Model.id)
                    return nil
            }
        }
    }
}

// MARK: Details / Emoji / Accessors
private extension ModelsNamespace.Emoji {
    func key() -> String { id }
    func value() -> Google_Protobuf_Value { .init(stringValue: self.value) }
}

// MARK: Details / Emoji / Converter
private extension ModelsNamespace.Emoji {
    enum Converter: _BlocksModelsParserDetailsConverterProtocol {
        typealias Model = TopLevel.AliasesMap.DetailsContent.Emoji
        static func asMiddleware(model: Model) -> Anytype_Rpc.Block.Set.Details.Detail? {
            .init(key: model.key(), value: model.value())
        }
        static func asModel(detail: Anytype_Rpc.Block.Set.Details.Detail) -> Model? {
            guard detail.key == Model.id else {
                let logger = Logging.createLogger(category: .blocksModelsModuleParserDetails)
                os_log(.debug, log: logger, "Can't proceed detail with key (%@) for predefined suffix. (%@)", detail.key, Model.id)
                return nil
            }
            switch detail.value.kind {
                case let .stringValue(string): return .init(value: string)
                default:
                    let logger = Logging.createLogger(category: .blocksModelsModuleParserDetails)
                    os_log(.debug, log: logger, "Unknown value (%@) for predefined suffix. %@", String(describing: detail), Model.id)
                    return nil
            }
        }
    }
}

// MARK: Details / OurHexColor / Accessors
private extension ModelsNamespace.OurHexColor {
    func key() -> String { id }
    func value() -> Google_Protobuf_Value { .init(stringValue: self.value) }
}

// MARK: Details / OurHexColor / Converter
private extension ModelsNamespace.OurHexColor {
    enum Converter: _BlocksModelsParserDetailsConverterProtocol {
        typealias Model = TopLevel.AliasesMap.DetailsContent.OurHexColor
        static func asMiddleware(model: Model) -> Anytype_Rpc.Block.Set.Details.Detail? {
            .init(key: model.key(), value: model.value())
        }
        static func asModel(detail: Anytype_Rpc.Block.Set.Details.Detail) -> Model? {
            guard detail.key == Model.id else {
                let logger = Logging.createLogger(category: .blocksModelsModuleParserDetails)
                os_log(.debug, log: logger, "Can't proceed detail with key (%@) for predefined suffix. (%@)", detail.key, Model.id)
                return nil
            }
            switch detail.value.kind {
                case let .stringValue(string): return .init(value: string)
                default:
                    let logger = Logging.createLogger(category: .blocksModelsModuleParserDetails)
                    os_log(.debug, log: logger, "Unknown value (%@) for predefined suffix. %@", String(describing: detail), Model.id)
                    return nil
            }
        }
    }
}

// MARK: Details / ImageId / Accessors
private extension ModelsNamespace.ImageId {
    func key() -> String { id }
    func value() -> Google_Protobuf_Value { .init(stringValue: self.value) }
}

// MARK: Details / ImageId / Converter
private extension ModelsNamespace.ImageId {
    enum Converter: _BlocksModelsParserDetailsConverterProtocol {
        typealias Model = TopLevel.AliasesMap.DetailsContent.ImageId
        static func asMiddleware(model: Model) -> Anytype_Rpc.Block.Set.Details.Detail? {
            .init(key: model.key(), value: model.value())
        }
        static func asModel(detail: Anytype_Rpc.Block.Set.Details.Detail) -> Model? {
            guard detail.key == Model.id else {
                let logger = Logging.createLogger(category: .blocksModelsModuleParserDetails)
                os_log(.debug, log: logger, "Can't proceed detail with key (%@) for predefined suffix. (%@)", detail.key, Model.id)
                return nil
            }
            switch detail.value.kind {
                case let .stringValue(string): return .init(value: string)
                default:
                    let logger = Logging.createLogger(category: .blocksModelsModuleParserDetails)
                    os_log(.debug, log: logger, "Unknown value (%@) for predefined suffix. %@", String(describing: detail), Model.id)
                    return nil
            }
        }
    }
}
