import Foundation

public final class SharingDI {
    
    public static let shared = SharingDI()
    
    private init() {}
    
    public func sharedContentManager() -> SharedContentManagerProtocol {
        SharedContentManager(sharedFileStorage: sharedFileStorage(), sharedContentImporter: sharedContentImporter())
    }
    
    private func sharedContentImporter() -> SharedContentImporterProtocol {
        SharedContentImporter(sharedFileStorage: sharedFileStorage())
    }
    
    private func sharedFileStorage() -> SharedFileStorageProtocol {
        SharedFileStorage()
    }
}
