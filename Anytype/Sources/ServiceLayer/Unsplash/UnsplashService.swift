import ProtobufMessages
import Combine
import Foundation
import AnytypeCore

protocol UnslpashItemDownloader {
    func downloadImage(id: String) async throws -> Hash
}

protocol UnsplashServiceProtocol: UnslpashItemDownloader {
    func searchUnsplashImages(query: String) async throws -> [UnsplashItem]
}

final class UnsplashService: UnsplashServiceProtocol {
    
    func searchUnsplashImages(query: String) async throws -> [UnsplashItem] {
        let result = try await ClientCommands.unsplashSearch(.with {
            $0.query = query
            $0.limit = 36
        }).invoke(errorDomain: .unsplash)
        
        return result.pictures.compactMap(UnsplashItem.init)
    }

    func downloadImage(id: String) async throws -> Hash {
        let result = try await ClientCommands.unsplashDownload(.with {
            $0.pictureID = id
        }).invoke(errorDomain: .unsplash)
        return try Hash(safeValue: result.hash)
    }
}
