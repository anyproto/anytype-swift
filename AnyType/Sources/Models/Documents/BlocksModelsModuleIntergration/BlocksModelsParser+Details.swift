import Foundation
import SwiftProtobuf
import ProtobufMessages
import Combine
import os
import BlocksModels


private extension LoggerCategory {
    static let blocksModelsParser: Self = "BlocksModelsParser"
}

// MARK: Details
extension BlocksModelsParser {
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
extension BlocksModelsParser.Details {
    /// Top converter which convert all details to and from protobuf.
    ///
    enum Converter: _BlocksModelsParserDetailsConverterProtocol {
        
        typealias Model = DetailsContent
        static func asMiddleware(model: Model) -> Anytype_Rpc.Block.Set.Details.Detail? {
            switch model {
            case let .name(value): return Model.Name.Converter.asMiddleware(model: value)
            case let .iconEmoji(value): return Model.Emoji.Converter.asMiddleware(model: value)
            case let .iconImage(value): return Model.ImageId.Converter.asMiddleware(model: value)
            }
        }

        // We can't put into one array all converters. But we doesn't care, haha.
        static func asModel(detail: Anytype_Rpc.Block.Set.Details.Detail) -> Model? {
            switch detail.key {
            case Model.Name.id: return Model.Name.Converter.asModel(detail: detail).flatMap(Model.name)
            case Model.Emoji.id: return Model.Emoji.Converter.asModel(detail: detail).flatMap(Model.iconEmoji)
            case Model.ImageId.id: return Model.ImageId.Converter.asModel(detail: detail).flatMap(Model.iconImage)
            default:
                // TODO: Add assertionFailure for debug when all converters will be added
                // TASK: https://app.clickup.com/t/h137nr
                Logger.create(.blocksModelsParser).error("Add converters for this type: \(detail.key)")
//                assertionFailure("Add converters for this type: \(detail.key)")
                return nil
            }
        }
    }
}

// MARK: Details / Title / Accessors
private extension DetailsContent.Name {
    func key() -> String { id }
    func value() -> Google_Protobuf_Value { .init(stringValue: self.value) }
}

// MARK: Details / Title / Converter
private extension DetailsContent.Name {
    enum Converter: _BlocksModelsParserDetailsConverterProtocol {
        typealias Model = DetailsContent.Name
        static func asMiddleware(model: Model) -> Anytype_Rpc.Block.Set.Details.Detail? {
            .init(key: model.key(), value: model.value())
        }
        static func asModel(detail: Anytype_Rpc.Block.Set.Details.Detail) -> Model? {
            guard detail.key == Model.id else {
                assertionFailure("Can't proceed detail with key \(detail.key) for predefined suffix. \(Model.id)")
                return nil
            }
            switch detail.value.kind {
                case let .stringValue(string): return .init(value: string)
                default:
                    assertionFailure("Unknown value \(detail) for predefined suffix. \(Model.id)")
                    return nil
            }
        }
    }
}

// MARK: Details / Emoji / Accessors
private extension DetailsContent.Emoji {
    func key() -> String { id }
    func value() -> Google_Protobuf_Value { .init(stringValue: self.value) }
}

// MARK: Details / Emoji / Converter
private extension DetailsContent.Emoji {
    enum Converter: _BlocksModelsParserDetailsConverterProtocol {
        typealias Model = DetailsContent.Emoji
        static func asMiddleware(model: Model) -> Anytype_Rpc.Block.Set.Details.Detail? {
            .init(key: model.key(), value: model.value())
        }
        static func asModel(detail: Anytype_Rpc.Block.Set.Details.Detail) -> Model? {
            guard detail.key == Model.id else {
                assertionFailure("Can't proceed detail with key \(detail.key) for predefined suffix. \(Model.id)")
                return nil
            }
            
            switch detail.value.kind {
            /// We don't display empty emoji so we must not create empty emoji details
            case let .stringValue(string) where string.isEmpty:
                return nil
            case let .stringValue(string):
                return .init(value: string)
            default:
                assertionFailure("Unknown value \(detail) for predefined suffix. \(Model.id)")
                return nil
            }
        }
    }
}

// MARK: Details / ImageId / Accessors
private extension DetailsContent.ImageId {
    func key() -> String { id }
    func value() -> Google_Protobuf_Value { .init(stringValue: self.value) }
}

// MARK: Details / ImageId / Converter
private extension DetailsContent.ImageId {
    enum Converter: _BlocksModelsParserDetailsConverterProtocol {
        typealias Model = DetailsContent.ImageId
        static func asMiddleware(model: Model) -> Anytype_Rpc.Block.Set.Details.Detail? {
            .init(key: model.key(), value: model.value())
        }
        static func asModel(detail: Anytype_Rpc.Block.Set.Details.Detail) -> Model? {
            guard detail.key == Model.id else {
                assertionFailure("Can't proceed detail with key \(detail.key) for predefined suffix. \(Model.id)")
                return nil
            }
            switch detail.value.kind {
                case let .stringValue(string): return .init(value: string)
                default:
                    assertionFailure("Unknown value \(detail) for predefined suffix. \(Model.id)")
                    return nil
            }
        }
    }
}
