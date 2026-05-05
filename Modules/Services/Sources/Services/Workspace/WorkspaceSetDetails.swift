import Foundation
import ProtobufMessages
import AnytypeCore
import SwiftProtobuf

public enum WorkspaceSetDetails: Sendable {
    case name(String)
    case description(String)
    case iconObjectId(String)
    case iconOption(Int)
    case spaceType(SpaceType)
}

extension WorkspaceSetDetails {

    var key: String {
        switch self {
        case .name: BundledPropertyKey.name.rawValue
        case .description: BundledPropertyKey.description.rawValue
        case .iconObjectId: BundledPropertyKey.iconImage.rawValue
        case .iconOption: BundledPropertyKey.iconOption.rawValue
        case .spaceType: BundledPropertyKey.spaceType.rawValue
        }
    }

    var value: Google_Protobuf_Value {
        switch self {
        case .name(let string): string.protobufValue
        case .description(let string): string.protobufValue
        case .iconObjectId(let objectId): objectId.protobufValue
        case .iconOption(let iconOption): iconOption.protobufValue
        case .spaceType(let spaceType): spaceType.rawValue.protobufValue
        }
    }
}
