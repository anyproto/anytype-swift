import ProtobufMessages
import Combine

protocol UnslpashItemDownloader {
    func downloadImage(id: String) -> AnyPublisher<String, Error>
}

protocol UnsplashServiceProtocol: UnslpashItemDownloader {
    func searchUnsplashImages(query: String) -> AnyPublisher<[UnsplashItem], Error>
}

final class UnsplashService: UnsplashServiceProtocol {
    private lazy var queue = DispatchQueue(label: "com.anytypeio.unsplash")

    func searchUnsplashImages(query: String) -> AnyPublisher<[UnsplashItem], Error> {
        Anytype_Rpc.Unsplash.Search.Service
            .invoke(query: query, limit: 36, queue: queue)
            .map { $0.pictures.compactMap(UnsplashItem.init) }
            .eraseToAnyPublisher()
    }

    func downloadImage(id: String) -> AnyPublisher<String, Error> {
        Anytype_Rpc.Unsplash.Download.Service
            .invoke(pictureID: id, queue: queue)
            .map { $0.hash }
            .eraseToAnyPublisher()
    }
}
