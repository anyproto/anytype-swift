import Foundation
import AnytypeCore
import ProtobufMessages
import SwiftProtobuf

public enum BundledDetails: Sendable {
    case name(String)
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
        case .name: BundledRelationKey.name.rawValue
        case .iconEmoji: BundledRelationKey.iconEmoji.rawValue
        case .iconObjectId: BundledRelationKey.iconImage.rawValue
        case .iconName: BundledRelationKey.iconName.rawValue
        case .iconOption: BundledRelationKey.iconOption.rawValue
        case .coverId: BundledRelationKey.coverId.rawValue
        case .coverType: BundledRelationKey.coverType.rawValue
        case .done: BundledRelationKey.done.rawValue
        case .description: BundledRelationKey.description.rawValue
        case .recommendedLayout: BundledRelationKey.recommendedLayout.rawValue
        case .lastUsedDate: BundledRelationKey.lastUsedDate.rawValue
        }
    }
    
    var value: Google_Protobuf_Value {
        switch self {
        case .name(let string): string.protobufValue
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
