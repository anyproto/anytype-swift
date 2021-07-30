import SwiftProtobuf
import AnytypeCore
import os

private extension LoggerCategory {
    static let detailsEntryConverter: Self = "DetailsEntryConverter"
}


public class DetailsEntryConverter {
    public static func convert(details: [String: Google_Protobuf_Value]) -> [DetailsKind: DetailsEntry<AnyHashable>] {
        Dictionary(
            uniqueKeysWithValues: details.compactMap { key, value -> (DetailsKind, DetailsEntry<AnyHashable>)? in
                guard let kind = DetailsKind(rawValue: key) else {
                    // TODO: Add anytypeAssertionFailure for debug when all converters will be added
                    // TASK: https://app.clickup.com/t/h137nr
                    os.Logger.create(.detailsEntryConverter).error("Add converters for this type: \(key)")
                    return nil
                }
                
                
                
                guard let entry = DetailsEntryConverter.convert(value: unwrapListValue(value), kind: kind) else {
                    return nil
                }
                
                return (kind, entry)
            }
        )
    }
    
    private static func unwrapListValue(_ value: Google_Protobuf_Value) -> Google_Protobuf_Value {
        // Relation fields (for example, iconEmoji/iconImage etc.) can come as single value or as list of values.
        // For current moment if we receive list of values we handle only first value of the list.
        if case let .listValue(listValue) = value.kind, let firstValue = listValue.values.first {
            return firstValue
        }
        return value
    }
    
    private static func convert(value: Google_Protobuf_Value, kind: DetailsKind) -> DetailsEntry<AnyHashable>? {
        return {
            switch kind {
            case .name:
                return value.asNameEntry()
            case .iconEmoji:
                return value.asIconEmojiEntry()
            case .iconImage:
                return value.asIconImageEntry()
            case .coverId:
                return value.asCoverIdEntry()
            case .coverType:
                return value.asCoverTypeEntry()
            case .isArchived:
                return value.asIsArchiveEntry()
            case .description:
                return value.asDescriptionEntry()
            case .layout:
                return value.asLayoutEntry()
            case .alignment:
                return value.asAlignmentEntry()
            case .done:
                return value.asDoneEntry()
            default:
//                anytypeAssertionFailure("TODO")
                return nil
            }
        }()
    }
}
