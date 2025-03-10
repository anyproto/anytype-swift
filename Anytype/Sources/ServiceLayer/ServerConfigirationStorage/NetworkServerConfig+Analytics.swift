import Services

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
