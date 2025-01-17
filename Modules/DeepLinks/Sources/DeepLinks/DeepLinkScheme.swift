import Foundation
import AppTarget

public enum DeepLinkScheme {
    case buildSpecific
    case main
}

extension DeepLinkScheme {
    
    private enum Scheme {
        static let dev = "dev-anytype://"
        static let prodAnytype = "prod-anytype://"
        static let prodAnyApp = "prod-anyapp://"
        static let main = "anytype://"
    }
    
    func host(targetType: AppTargetType) -> String {
        switch self {
        case .buildSpecific:
            return currentDebugSchema(targetType: targetType)
        case .main:
            return Scheme.main
        }
    }
    
    private func currentDebugSchema(targetType: AppTargetType) -> String {
        switch targetType {
        case .debug:
            Scheme.dev
        case .releaseAnytype:
            Scheme.prodAnytype
        case .releaseAnyApp:
            Scheme.prodAnyApp
        }
    }
}
