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

    static func asMiddleware(models: [DetailsEntry<AnyHashable>]) -> [Anytype_Rpc.Block.Set.Details.Detail]
    static func asModel(details: [Anytype_Rpc.Block.Set.Details.Detail]) -> [DetailsEntry<AnyHashable>]
    
}

// MARK: Details / Converter
extension BlocksModelsParser.Details {
    /// Top converter which convert all details to and from protobuf.
    ///
    enum Converter: _BlocksModelsParserDetailsConverterProtocol {
        
        static func asMiddleware(models: [DetailsEntry<AnyHashable>]) -> [Anytype_Rpc.Block.Set.Details.Detail] {
            models.compactMap { $0.asMiddleware }
        }
        
        static func asModel(details: [Anytype_Rpc.Block.Set.Details.Detail]) -> [DetailsEntry<AnyHashable>] {
            details.compactMap { $0.asModel }
        }
    }
    
}

private extension DetailsEntry {
    
    var asMiddleware: Anytype_Rpc.Block.Set.Details.Detail? {
        let protobufValue: Google_Protobuf_Value? = {
            if let string = self.value as? String {
                return Google_Protobuf_Value(stringValue: string)
            }
            
            if let double = self.value as? Double {
                return Google_Protobuf_Value(numberValue: double)
            }
            
            assertionFailure("Implement converter from \(V.self) to `Google_Protobuf_Value`")
            return nil
        }()
        
        return protobufValue.flatMap {
            Anytype_Rpc.Block.Set.Details.Detail(
                key: self.id,
                value: $0
            )
        }
    }
    
}

private extension Anytype_Rpc.Block.Set.Details.Detail {
    
    var asModel: DetailsEntry<AnyHashable>? {
        guard let kind = DetailsKind(rawValue: self.key) else {
            // TODO: Add assertionFailure for debug when all converters will be added
            // TASK: https://app.clickup.com/t/h137nr
            Logger.create(.blocksModelsParser).error("Add converters for this type: \(self.key)")
//                assertionFailure("Add converters for this type: \(detail.key)")
            return nil
        }
        
        switch kind {
        case .name:
            return asNameEntry()
        case .iconEmoji:
            return asIconEmojiEntry()
        case .iconImage:
            return asIconImageEntry()
        case .coverId:
            return asCoverIdEntry()
        case .coverType:
            return asCoverTypeEntry()
        }
    }
    
    func asNameEntry() -> DetailsEntry<AnyHashable>? {
        switch self.value.kind {
        case let .stringValue(string):
            return DetailsEntry(kind: .name, value: string)
        default:
            assertionFailure(
                "Unknown value \(self) for predefined suffix. \(DetailsKind.name)"
            )
            return nil
        }
    }
    
    func asIconEmojiEntry() -> DetailsEntry<AnyHashable>? {
        switch self.value.kind {
        /// We don't display empty emoji so we must not create empty emoji details
        case let .stringValue(string) where string.isEmpty:
            return nil
        case let .stringValue(string):
            return DetailsEntry(kind: .iconEmoji, value: string)
        default:
            assertionFailure(
                "Unknown value \(self) for predefined suffix. \(DetailsKind.iconEmoji)"
            )
            return nil
        }
    }
    
    func asIconImageEntry() -> DetailsEntry<AnyHashable>? {
        switch self.value.kind {
        case let .stringValue(string):
            return DetailsEntry(kind: .iconImage, value: string)
        default:
            assertionFailure(
                "Unknown value \(self) for predefined suffix. \(DetailsKind.iconImage)"
            )
            return nil
        }
    }
    
    func asCoverIdEntry() -> DetailsEntry<AnyHashable>? {
        switch value.kind {
        case let .stringValue(string):
            return DetailsEntry(kind: .coverId, value: string)
        default:
            assertionFailure(
                "Unknown value \(self) for predefined suffix. \(DetailsKind.coverId)"
            )
            return nil
        }
    }
    
    func asCoverTypeEntry() -> DetailsEntry<AnyHashable>? {
        switch value.kind {
        case let .numberValue(number):
            guard let coverType = CoverType(rawValue: Int(number)) else { return nil }
            
            return DetailsEntry(kind: .coverType, value: coverType)
        default:
            assertionFailure(
                "Unknown value \(self) for predefined suffix. \(DetailsKind.coverType)"
            )
            return nil
        }
    }
    
}
