import Foundation

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
    
    func host(isDebug: Bool) -> String {
        switch self {
        case .buildSpecific:
            return currentDebugSchema(isDebug: isDebug)
        case .main:
            return Scheme.main
        }
    }
    
    private func currentDebugSchema(isDebug: Bool) -> String {
        return isDebug ? Scheme.dev : Scheme.prod
    }
}
