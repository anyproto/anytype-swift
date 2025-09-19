import Foundation
import AnytypeCore
import ProtobufMessages
import SwiftProtobuf

public enum BundledDetails: Sendable {
    case name(String)
    case pluralName(String)
    case iconEmoji(String)
    case iconObjectId(String)
    case iconName(String)
    case iconOption(Int)
    case coverId(String)
    case coverType(CoverType)
    case done(Bool)
    case description(String)
    case recommendedLayout(Int)
    case lastUsedDate(Date)
}

extension BundledDetails {
    
    var key: String {
        switch self {
        case .name: BundledPropertyKey.name.rawValue
        case .pluralName: BundledPropertyKey.pluralName.rawValue
        case .iconEmoji: BundledPropertyKey.iconEmoji.rawValue
        case .iconObjectId: BundledPropertyKey.iconImage.rawValue
        case .iconName: BundledPropertyKey.iconName.rawValue
        case .iconOption: BundledPropertyKey.iconOption.rawValue
        case .coverId: BundledPropertyKey.coverId.rawValue
        case .coverType: BundledPropertyKey.coverType.rawValue
        case .done: BundledPropertyKey.done.rawValue
        case .description: BundledPropertyKey.description.rawValue
        case .recommendedLayout: BundledPropertyKey.recommendedLayout.rawValue
        case .lastUsedDate: BundledPropertyKey.lastUsedDate.rawValue
        }
    }
    
    var value: Google_Protobuf_Value {
        switch self {
        case .name(let string): string.protobufValue
        case .pluralName(let string): string.protobufValue
        case .iconEmoji(let string): string.protobufValue
        case .iconObjectId(let string): string.protobufValue
        case .iconName(let string): string.protobufValue
        case .iconOption(let int): int.protobufValue
        case .coverId(let string): string.protobufValue
        case .coverType(let coverType): coverType.rawValue.protobufValue
        case .done(let bool): bool.protobufValue
        case .description(let string): string.protobufValue
        case .recommendedLayout(let layout): layout.protobufValue
        case .lastUsedDate(let date): date.protobufValue
        }
    }
    
}
