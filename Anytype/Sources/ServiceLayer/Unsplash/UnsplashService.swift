import ProtobufMessages
import Combine
import Foundation

final class UnsplashService {
    private lazy var queue = DispatchQueue(label: "com.anytypeio.unsplash")

    func searchUnsplashImages(query: String) -> AnyPublisher<[UnsplashItem], Error> {
        Anytype_Rpc.UnsplashSearch.Service
            .invoke(query: query, limit: 36, queue: queue)
            .map { $0.pictures.compactMap(UnsplashItem.init) }
            .eraseToAnyPublisher()
    }

    func downloadImage(id: String) -> AnyPublisher<Data?, Error> {
        Anytype_Rpc.UnsplashDownload.Service
            .invoke(pictureID: id, queue: queue)
            .map { try? $0.serializedData() }
            .eraseToAnyPublisher()
    }
}
