import Foundation
import ProtobufMessages

public protocol GalleryServiceProtocol: AnyObject {
    func manifest(url: String) async throws -> GalleryManifest
    func importExperience(spaceId: String, isNewSpace: Bool, title: String, url: String) async throws
}

public final class GalleryService: GalleryServiceProtocol {
    
    public init() {}
    
    // MARK: - GalleryServiceProtocol
    
    public func manifest(url: String) async throws -> GalleryManifest {
        let response = try await ClientCommands.galleryDownloadManifest(.with {
            $0.url = url
        }).invoke()
        return GalleryManifest(from: response.info)
    }
    
    public func importExperience(spaceId: String, isNewSpace: Bool, title: String, url: String) async throws {
        try await ClientCommands.objectImportExperience(.with {
            $0.spaceID = spaceId
            $0.isNewSpace = isNewSpace
            $0.title = title
            $0.url = url
        }).invoke()
    }
}
