import Foundation
import SwiftProtobuf
import ProtobufMessages
import Combine
import os
import BlocksModels

private extension LoggerCategory {
    static let blocksModelsParser: Self = "BlocksModelsParser"
}

/// Top converter which convert all details to and from protobuf.
enum BlocksModelsDetailsConverter {
    static func asMiddleware(models: [DetailsKind: DetailsEntry<AnyHashable>]) -> [Anytype_Rpc.Block.Set.Details.Detail] {
        models.compactMap { row in
            Anytype_Rpc.Block.Set.Details.Detail.converted(
                kind: row.key,
                entry: row.value
            )
        }
    }
    
    static func asModel(details: [Anytype_Rpc.Block.Set.Details.Detail]) -> [DetailsKind:  DetailsEntry<AnyHashable>] {
        details.asModel()
    }
    
    static func asModel(details: [Anytype_Event.Object.Details.Amend.KeyValue]) -> [DetailsKind: DetailsEntry<AnyHashable>] {
        details.asModel()
    }
}

private extension Anytype_Rpc.Block.Set.Details.Detail {

    static func converted(kind: DetailsKind, entry: DetailsEntry<AnyHashable>) -> Self? {
        let protobufValue: Google_Protobuf_Value? = {
            if let string = entry.value as? String {
                return Google_Protobuf_Value(stringValue: string)
            }
            
            if let coverType = entry.value as? CoverType {
                return Google_Protobuf_Value(
                    numberValue: Double(coverType.rawValue)
                )
            }
            
            assertionFailure("Implement converter from \(entry.value) to `Google_Protobuf_Value`")
            return nil
        }()
        
        guard let protobufValue = protobufValue else { return nil }
        
        return Anytype_Rpc.Block.Set.Details.Detail(
            key: kind.rawValue,
            value: protobufValue
        )
    }
    
}

private extension Array where Element == Anytype_Rpc.Block.Set.Details.Detail {
    
    func asModel() -> [DetailsKind: DetailsEntry<AnyHashable>] {
        var result: [DetailsKind: DetailsEntry<AnyHashable>] = [:]
        
        self.forEach { element in
            guard let kind = DetailsKind(rawValue: element.key) else {
                // TODO: Add assertionFailure for debug when all converters will be added
                // TASK: https://app.clickup.com/t/h137nr
                Logger.create(.blocksModelsParser).error("Add converters for this type: \(element.key)")
    //                assertionFailure("Add converters for this type: \(detail.key)")
                return
            }
            
            let value: DetailsEntry<AnyHashable>? = {
                switch kind {
                case .name:
                    return element.value.asNameEntry()
                case .iconEmoji:
                    return element.value.asIconEmojiEntry()
                case .iconImage:
                    return element.value.asIconImageEntry()
                case .coverId:
                    return element.value.asCoverIdEntry()
                case .coverType:
                    return element.value.asCoverTypeEntry()
                case .isArchived:
                    return element.value.asIsArchiveEntry()
                }
            }()
            
            value.flatMap {
                result[kind] = $0
            }
        }
        
        return result
    }
    
}

private extension Array where Element == Anytype_Event.Object.Details.Amend.KeyValue {
    
    func asModel() -> [DetailsKind: DetailsEntry<AnyHashable>] {
        var result: [DetailsKind: DetailsEntry<AnyHashable>] = [:]
        
        self.forEach { element in
            guard let kind = DetailsKind(rawValue: element.key) else {
                // TODO: Add assertionFailure for debug when all converters will be added
                // TASK: https://app.clickup.com/t/h137nr
                Logger.create(.blocksModelsParser).error("Add converters for this type: \(element.key)")
    //                assertionFailure("Add converters for this type: \(detail.key)")
                return
            }
            
            let value: DetailsEntry<AnyHashable>? = {
                switch kind {
                case .name:
                    return element.value.asNameEntry()
                case .iconEmoji:
                    return element.value.asIconEmojiEntry()
                case .iconImage:
                    return element.value.asIconImageEntry()
                case .coverId:
                    return element.value.asCoverIdEntry()
                case .coverType:
                    return element.value.asCoverTypeEntry()
                case .isArchived:
                    return element.value.asIsArchiveEntry()
                }
            }()
            
            value.flatMap {
                result[kind] = $0
            }
        }
        
        return result
    }
    
}

private extension Google_Protobuf_Value {
    
    func asNameEntry() -> DetailsEntry<AnyHashable>? {
        switch kind {
        case let .stringValue(string):
            return DetailsEntry(value: string)
        default:
            assertionFailure(
                "Unknown value \(self) for predefined suffix. \(DetailsKind.name)"
            )
            return nil
        }
    }
    
    func asIconEmojiEntry() -> DetailsEntry<AnyHashable>? {
        switch kind {
        case let .stringValue(string):
            return DetailsEntry(value: string)
        default:
            assertionFailure(
                "Unknown value \(self) for predefined suffix. \(DetailsKind.iconEmoji)"
            )
            return nil
        }
    }
    
    func asIconImageEntry() -> DetailsEntry<AnyHashable>? {
        switch self.kind {
        case let .stringValue(string):
            return DetailsEntry(value: string)
        default:
            assertionFailure(
                "Unknown value \(self) for predefined suffix. \(DetailsKind.iconImage)"
            )
            return nil
        }
    }
    
    func asCoverIdEntry() -> DetailsEntry<AnyHashable>? {
        switch kind {
        case let .stringValue(string):
            return DetailsEntry(value: string)
        default:
            assertionFailure(
                "Unknown value \(self) for predefined suffix. \(DetailsKind.coverId)"
            )
            return nil
        }
    }
    
    func asCoverTypeEntry() -> DetailsEntry<AnyHashable>? {
        switch kind {
        case let .numberValue(number):
            guard let coverType = CoverType(rawValue: Int(number)) else { return nil }
            
            return DetailsEntry(value: coverType)
        default:
            assertionFailure(
                "Unknown value \(self) for predefined suffix. \(DetailsKind.coverType)"
            )
            return nil
        }
    }
    
    func asIsArchiveEntry() -> DetailsEntry<AnyHashable>? {
        switch kind {
        case .boolValue(let isArchive):
            return DetailsEntry(value: isArchive)
        default:
            assertionFailure(
                "Unknown value \(self) for predefined suffix. \(DetailsKind.isArchived)"
            )
            return nil
        }
    }
    
}
