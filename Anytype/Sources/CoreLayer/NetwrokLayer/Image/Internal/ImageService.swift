import Foundation
import Combine
import UIKit


final class ImageService {
    func fetchImage(url: URL) -> AnyPublisher<UIImage?, Error> {
        URLSession.shared.dataTaskPublisher(for: url).map({UIImage(data: $0.data)})
            .mapError({$0}) // Bug?
            .eraseToAnyPublisher()
    }
    
    func fetchImageAndIgnoreError(url: URL) -> AnyPublisher<UIImage?, Never> {
        self.fetchImage(url: url).ignoreFailure().eraseToAnyPublisher()
    }
}
