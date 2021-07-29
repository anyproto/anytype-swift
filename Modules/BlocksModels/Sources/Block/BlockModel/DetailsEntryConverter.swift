import SwiftProtobuf
import AnytypeCore
import os

private extension LoggerCategory {
    static let detailsEntryConverter: Self = "DetailsEntryConverter"
}


public class DetailsEntryConverter {
    public static func convert(details: [String: Google_Protobuf_Value]) -> [DetailsKind: DetailsEntry<AnyHashable>] {
        var result: [DetailsKind: DetailsEntry<AnyHashable>] = [:]
        
        details.forEach { key, value in
            guard let kind = DetailsKind(rawValue: key) else {
                // TODO: Add anytypeAssertionFailure for debug when all converters will be added
                // TASK: https://app.clickup.com/t/h137nr
                os.Logger.create(.detailsEntryConverter).error("Add converters for this type: \(key)")
    //                anytypeAssertionFailure("Add converters for this type: \(detail.key)")
                return
            }
            
            let value = DetailsEntryConverter.convert(value: value, kind: kind)
            value.flatMap { result[kind] = $0}
        }
        
        return result
    }
    
    public static func convert(value: Google_Protobuf_Value, kind: DetailsKind) -> DetailsEntry<AnyHashable>? {
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
