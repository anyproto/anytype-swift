import Foundation
import ProtobufMessages
import AnytypeCore
import SwiftProtobuf

public enum WorkspaceSetDetails: Sendable {
    case name(String)
    case description(String)
    case iconObjectId(String)
    case iconOption(Int)
}

extension WorkspaceSetDetails {
    
    var key: String {
        switch self {
        case .name: BundledRelationKey.name.rawValue
        case .description: BundledRelationKey.description.rawValue
        case .iconObjectId: BundledRelationKey.iconImage.rawValue
        case .iconOption: BundledRelationKey.iconOption.rawValue
        }
    }
    
    var value: Google_Protobuf_Value {
        switch self {
        case .name(let string): string.protobufValue
        case .description(let string): string.protobufValue
        case .iconObjectId(let objectId): objectId.protobufValue
        case .iconOption(let iconOption): iconOption.protobufValue
        }
    }
}
