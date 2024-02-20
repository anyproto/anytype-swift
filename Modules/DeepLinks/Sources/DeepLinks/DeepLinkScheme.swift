import Foundation
import AnytypeCore


public enum DeepLinkScheme {
    case buildSpecific
    case main
}

extension DeepLinkScheme {
    
    private enum Scheme {
        static let dev = "dev-anytype://"
        static let prod = "prod-anytype://"
        static let main = "anytype://"
    }
    
    func host() -> String {
        switch self {
        case .buildSpecific:
            return currentDebugSchema()
        case .main:
            return Scheme.main
        }
    }
    
    private func currentDebugSchema() -> String {
        return CoreEnvironment.isDebug ? Scheme.dev : Scheme.prod
    }
}
