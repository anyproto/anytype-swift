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
        
        static func asMiddleware(model: DetailsEntry) -> Anytype_Rpc.Block.Set.Details.Detail? {
            model.asMiddleware
        }

        // We can't put into one array all converters. But we doesn't care, haha.
        static func asModel(detail: Anytype_Rpc.Block.Set.Details.Detail) -> DetailsEntry? {
            detail.asModel
        }
    }
}

private extension DetailsEntry {
    
    var asMiddleware: Anytype_Rpc.Block.Set.Details.Detail {
        Anytype_Rpc.Block.Set.Details.Detail(
            key: self.id,
            value: Google_Protobuf_Value(
                stringValue: self.value
            )
        )
    }
    
}

private extension Anytype_Rpc.Block.Set.Details.Detail {
    
    var asModel: DetailsEntry? {
        guard let kind = DetailsKind(rawValue: self.key) else {
            // TODO: Add assertionFailure for debug when all converters will be added
            // TASK: https://app.clickup.com/t/h137nr
            Logger.create(.blocksModelsParser).error("Add converters for this type: \(self.key)")
//                assertionFailure("Add converters for this type: \(detail.key)")
            return nil
        }
        
        switch kind {
        case .name:
            return makeNameEntry(using: self)
        case .iconEmoji:
            return makeIconEmojiEntry(using: self)
        case .iconImage:
            return makeIconImageEntry(using: self)
        }
    }
    
    func makeNameEntry(using detail: Anytype_Rpc.Block.Set.Details.Detail) -> DetailsEntry? {
        switch detail.value.kind {
        case let .stringValue(string):
            return DetailsEntry(kind: .name, value: string)
        default:
            assertionFailure(
                "Unknown value \(detail) for predefined suffix. \(DetailsKind.name)"
            )
            return nil
        }
    }
    
    func makeIconEmojiEntry(using detail: Anytype_Rpc.Block.Set.Details.Detail) -> DetailsEntry? {
        switch detail.value.kind {
        /// We don't display empty emoji so we must not create empty emoji details
        case let .stringValue(string) where string.isEmpty:
            return nil
        case let .stringValue(string):
            return DetailsEntry(kind: .iconEmoji, value: string)
        default:
            assertionFailure(
                "Unknown value \(detail) for predefined suffix. \(DetailsKind.iconEmoji)"
            )
            return nil
        }
    }
    
    func makeIconImageEntry(using detail: Anytype_Rpc.Block.Set.Details.Detail) -> DetailsEntry? {
        switch detail.value.kind {
        case let .stringValue(string):
            return DetailsEntry(kind: .iconImage, value: string)
        default:
            assertionFailure(
                "Unknown value \(detail) for predefined suffix. \(DetailsKind.iconImage)"
            )
            return nil
        }
    }
    
}
