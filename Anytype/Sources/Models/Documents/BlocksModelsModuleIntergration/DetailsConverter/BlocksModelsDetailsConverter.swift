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

            // Relation fields (for example, iconEmoji/iconImage etc.) can come as single value or as list of values.
            // For current moment if we receive list of values we handle only first value of the list.
            var protoValue = element.value
            if case let .listValue(listValue) = element.value.kind, let firstValue = listValue.values.first {
                protoValue = firstValue
            }
            
            let value = DetailsEntryConverter.convert(value: protoValue, kind: kind)
            value.flatMap { result[kind] = $0}
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
            
            let value = DetailsEntryConverter.convert(value: element.value, kind: kind)
            value.flatMap { result[kind] = $0 }
        }
        
        return result
    }
}
