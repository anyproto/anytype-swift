import Foundation
import ProtobufMessages

enum NetworkServerConfig: Codable, Equatable {
    case anytype
    case localOnly
    case file(_ name: String)
}

extension NetworkServerConfig {
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

extension NetworkServerConfig {
    var analyticsType: SelectNetworkType {
        switch self {
        case .anytype:
            return .anytype
        case .localOnly:
            return .localOnly
        case .file:
            return .selfHost
        }
    }
}
