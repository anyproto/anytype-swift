import Foundation
import SwiftProtobuf
import ProtobufMessages
import Combine
import os
import BlocksModels
import AnytypeCore

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
            
            if let layout = entry.value as? DetailsLayout {
                return Google_Protobuf_Value(
                    numberValue: Double(layout.rawValue)
                )
            }
            
            anytypeAssertionFailure("Implement converter from \(entry.value) to `Google_Protobuf_Value`")
            return nil
        }()
        
        guard let value = protobufValue else { return nil }
        
        return Anytype_Rpc.Block.Set.Details.Detail(
            key: kind.rawValue,
            value: value
        )
    }
    
}

private extension Array where Element == Anytype_Rpc.Block.Set.Details.Detail {
    
    func asModel() -> [DetailsKind: DetailsEntry<AnyHashable>] {
        var result: [DetailsKind: DetailsEntry<AnyHashable>] = [:]
        
        self.forEach { element in
            guard let kind = DetailsKind(rawValue: element.key) else {
                // TODO: Add anytypeAssertionFailure for debug when all converters will be added
                // TASK: https://app.clickup.com/t/h137nr
                Logger.create(.blocksModelsParser).error("Add converters for this type: \(element.key)")
    //                anytypeAssertionFailure("Add converters for this type: \(detail.key)")
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
                case .description:
                    return element.value.asDescriptionEntry()
                case .layout:
                    return element.value.asLayoutEntry()
                case .alignment:
                    return element.value.asAlignmentEntry()
                case .done:
                    return element.value.asDoneEntry()
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
                // TODO: Add anytypeAssertionFailure for debug when all converters will be added
                // TASK: https://app.clickup.com/t/h137nr
                Logger.create(.blocksModelsParser).error("Add converters for this type: \(element.key)")
    //                anytypeAssertionFailure("Add converters for this type: \(detail.key)")
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
                case .description:
                    return element.value.asDescriptionEntry()
                case .layout:
                    return element.value.asLayoutEntry()
                case .alignment:
                    return element.value.asAlignmentEntry()
                case .done:
                    return element.value.asDoneEntry()
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
        guard case let .stringValue(string) = kind else {
            anytypeAssertionFailure(
                "Unknown value \(self) for predefined suffix. \(DetailsKind.name)"
            )
            return nil
        }
        
        return DetailsEntry(value: string)
    }
    
    func asIconEmojiEntry() -> DetailsEntry<AnyHashable>? {
        guard case let .stringValue(string) = kind else {
            anytypeAssertionFailure(
                "Unknown value \(self) for predefined suffix. \(DetailsKind.iconEmoji)"
            )
            return nil
        }
        
        return DetailsEntry(value: string)
    }
    
    func asIconImageEntry() -> DetailsEntry<AnyHashable>? {
        guard case let .stringValue(string) = kind else {
            anytypeAssertionFailure(
                "Unknown value \(self) for predefined suffix. \(DetailsKind.iconImage)"
            )
            return nil
        }
        
        return DetailsEntry(value: string)
    }
    
    func asCoverIdEntry() -> DetailsEntry<AnyHashable>? {
        guard case let .stringValue(string) = kind else {
            anytypeAssertionFailure(
                "Unknown value \(self) for predefined suffix. \(DetailsKind.coverId)"
            )
            return nil
        }
        return DetailsEntry(value: string)
    }
    
    func asCoverTypeEntry() -> DetailsEntry<AnyHashable>? {
        guard let number = self.safeIntValue else {
            anytypeAssertionFailure(
                "Unknown value \(self) for predefined suffix. \(DetailsKind.coverType)"
            )
            return nil
        }
        
        guard let coverType = CoverType(rawValue: number) else { return nil }
        
        return DetailsEntry(value: coverType)
    }
    
    func asIsArchiveEntry() -> DetailsEntry<AnyHashable>? {
        guard case .boolValue(let isArchive) = kind else {
            anytypeAssertionFailure(
                "Unknown value \(self) for predefined suffix. \(DetailsKind.isArchived)"
            )
            return nil
        }
        
        return DetailsEntry(value: isArchive)
    }
    
    func asDescriptionEntry() -> DetailsEntry<AnyHashable>? {
        guard case let .stringValue(string) = kind else {
            anytypeAssertionFailure(
                "Unknown value \(self) for predefined suffix. \(DetailsKind.description)"
            )
            return nil
        }
        
        return DetailsEntry(value: string)
    }
    
    func asLayoutEntry() -> DetailsEntry<AnyHashable>? {
        guard let number = self.safeIntValue else {
            anytypeAssertionFailure(
                "Unknown value \(self) for predefined suffix. \(DetailsKind.description)"
            )
            return nil
        }
        guard let layout = DetailsLayout(rawValue: number) else { return nil }
        
        return DetailsEntry(value: layout)
    }
    
    func asAlignmentEntry() -> DetailsEntry<AnyHashable>? {
        guard let number = self.safeIntValue else {
            anytypeAssertionFailure(
                "Unknown value \(self) for predefined suffix. \(DetailsKind.description)"
            )
            return nil
        }
        guard let layout = LayoutAlignment(rawValue: number) else { return nil }
        
        return DetailsEntry(value: layout)
    }
    
    func asDoneEntry() -> DetailsEntry<AnyHashable>? {
        guard case let .boolValue(bool) = kind else {
            anytypeAssertionFailure(
                "Unknown value \(self) for predefined suffix. \(DetailsKind.description)"
            )
            return nil
        }
        return DetailsEntry(value: bool)
    }
    
}
