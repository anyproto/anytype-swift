import Foundation
import ProtobufMessages
import AnytypeCore
import SwiftProtobuf

public enum WorkspaceSetDetails {
    case name(String)
    case iconImageHash(Hash?)
}

extension WorkspaceSetDetails {
    
    var key: String {
        switch self {
        case .name: return BundledRelationKey.name.rawValue
        case .iconImageHash: return BundledRelationKey.iconImage.rawValue
        }
    }
    
    var value: Google_Protobuf_Value {
        switch self {
        case .name(let string): return string.protobufValue
        case .iconImageHash(let hash): return (hash?.value ?? "").protobufValue
        }
    }
}
