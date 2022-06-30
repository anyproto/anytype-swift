import ProtobufMessages
import Foundation

struct UnsplashItem {
    let id: String
    let url: URL
    let artistName: String
    let artistURL: URL
}


// MARK: - Unsplash + Middleware

extension UnsplashItem {
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

extension UnsplashItem {
    var updateEvent: LocalEvent { .header(.coverUploading(.remotePreviewURL(url))) }
}
