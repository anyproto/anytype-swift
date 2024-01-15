import Foundation

public final class SharingDI {
    
    public static let shared = SharingDI()
    
    private init() {}
    
    public static func sharedContentManager() -> SharedContentManagerProtocol {
        SharedContentManager()
    }
}
