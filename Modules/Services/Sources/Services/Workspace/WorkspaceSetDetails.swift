import Foundation
import ProtobufMessages
import AnytypeCore
import SwiftProtobuf

public enum WorkspaceSetDetails {
    case name(String)
    case iconObjectId(String)
}

extension WorkspaceSetDetails {
    
    var key: String {
        switch self {
        case .name: return BundledRelationKey.name.rawValue
        case .iconObjectId: return BundledRelationKey.iconImage.rawValue
        }
    }
    
    var value: Google_Protobuf_Value {
        switch self {
        case .name(let string): return string.protobufValue
        case .iconObjectId(let objectId): return objectId.protobufValue
        }
    }
}
