import ProtobufMessages
import Combine
import Foundation
import AnytypeCore

public protocol UnsplashServiceProtocol {
    func searchUnsplashImages(query: String) async throws -> [UnsplashItem]
    func downloadImage(spaceId: String, id: String) async throws -> ObjectId
}

public final class UnsplashService: UnsplashServiceProtocol {
    
    public init() {}
    
    public func searchUnsplashImages(query: String) async throws -> [UnsplashItem] {
        let result = try await ClientCommands.unsplashSearch(.with {
            $0.query = query
            $0.limit = 36
        }).invoke()
        
        return result.pictures.compactMap(UnsplashItem.init)
    }

    public func downloadImage(spaceId: String, id: String) async throws -> String {
        let result = try await ClientCommands.unsplashDownload(.with {
            $0.pictureID = id
            $0.spaceID = spaceId
        }).invoke()
        return result.objectID
    }
}
