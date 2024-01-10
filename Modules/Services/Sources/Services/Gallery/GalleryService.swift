import Foundation
import ProtobufMessages

public protocol GalleryServiceProtocol: AnyObject {
    func manifest(url: String) async throws -> GalleryManifest
}

public final class GalleryService: GalleryServiceProtocol {
    
    public init() {}
    
    // MARK: - GalleryServiceProtocol
    
    public func manifest(url: String) async throws -> GalleryManifest {
        let response = try await ClientCommands.downloadManifest(.with {
            $0.url = url
        }).invoke()
        return GalleryManifest(from: response.info)
    }
}
