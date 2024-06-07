import ProtobufMessages
import Foundation

public struct UnsplashItem: Sendable {
    public let id: String
    public let url: URL
    public let artistName: String
    public let artistURL: URL
}


// MARK: - Unsplash + Middleware

public extension UnsplashItem {
    init?(model: Anytype_Rpc.Unsplash.Search.Response.Picture) {
        guard let url = URL(string: model.url),
              let artistsURL = URL(string: model.artistURL) else {
                  return nil
              }

        self.id = model.id
        self.url = url
        self.artistName = model.artist
        self.artistURL = artistsURL
    }
}
