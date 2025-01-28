import Foundation
import AppTarget

public final class DeepLinkDI: Sendable {
    
    public static let shared = DeepLinkDI()
    
    private init() {}
    
    public func parser(targetType: AppTargetType) -> DeepLinkParserProtocol {
        DeepLinkParser(targetType: targetType)
    }
}
