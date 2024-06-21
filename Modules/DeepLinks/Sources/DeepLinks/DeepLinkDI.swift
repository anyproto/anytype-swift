import Foundation

public final class DeepLinkDI: Sendable {
    
    public static let shared = DeepLinkDI()
    
    private init() {}
    
    public func parser(isDebug: Bool) -> DeepLinkParserProtocol {
        DeepLinkParser(isDebug: isDebug)
    }
}
