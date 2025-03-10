import Foundation
import ProtobufMessages

public enum NetworkServerConfig: Codable, Equatable, Sendable {
    case anytype
    case localOnly
    case file(_ name: String)
    
    public var isLocalOnly: Bool {
        self == .localOnly
    }
}

public extension NetworkServerConfig {
    var middlewareNetworkMode:  Anytype_Rpc.Account.NetworkMode {
        switch self {
        case .anytype:
            return .defaultConfig
        case .localOnly:
            return .localOnly
        case .file:
            return .customConfig
        }
    }
}
