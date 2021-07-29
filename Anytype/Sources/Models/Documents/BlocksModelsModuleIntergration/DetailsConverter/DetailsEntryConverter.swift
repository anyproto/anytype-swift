import BlocksModels
import SwiftProtobuf
import AnytypeCore

class DetailsEntryConverter {
    static func convert(value: Google_Protobuf_Value, kind: DetailsKind) -> DetailsEntry<AnyHashable>? {
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
