import ProtobufMessages
import Combine
import Foundation
import AnytypeCore

public protocol UnsplashServiceProtocol: Sendable {
    func searchUnsplashImages(query: String) async throws -> [UnsplashItem]
    func downloadImage(spaceId: String, id: String, createdInContext: String, createdInContextRef: String) async throws -> ObjectId
}

public extension UnsplashServiceProtocol {
    func downloadImage(spaceId: String, id: String) async throws -> ObjectId {
        try await downloadImage(spaceId: spaceId, id: id, createdInContext: "", createdInContextRef: "")
    }
}

final class UnsplashService: UnsplashServiceProtocol {
    
    public func searchUnsplashImages(query: String) async throws -> [UnsplashItem] {
        let result = try await ClientCommands.unsplashSearch(.with {
            $0.query = query
            $0.limit = 36
        }).invoke(ignoreLogErrors: .unknownError)
        
        return result.pictures.compactMap(UnsplashItem.init)
    }

    public func downloadImage(spaceId: String, id: String, createdInContext: String, createdInContextRef: String) async throws -> String {
        let result = try await ClientCommands.unsplashDownload(.with {
            $0.pictureID = id
            $0.spaceID = spaceId
            $0.createdInContext = createdInContext
            $0.createdInContextRef = createdInContextRef
        }).invoke()
        return result.objectID
    }
}
