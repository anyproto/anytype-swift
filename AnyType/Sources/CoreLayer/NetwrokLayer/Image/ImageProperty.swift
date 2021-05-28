import Combine
import UIKit
import os


class ImageProperty {
    @Published var property: UIImage?
    var stream: AnyPublisher<UIImage?, Never> = .empty()
    
    private var subscriptions: [AnyCancellable] = []
    
    init(imageId: String, _ parameters: ImageParameters = .init(width: .default)) {
        setUpCacheSubscription(imageId: imageId, parameters: parameters)
        setUpLoadSubscription(imageId: imageId, parameters: parameters)
    }
    
    private func setUpCacheSubscription(imageId: String, parameters: ImageParameters) {
        ImageCache.shared.publisher(imageId: imageId, parameters)
            .sink { [weak self] (value) in
                self?.property = value
            }.store(in: &subscriptions)
    }
    
    private func setUpLoadSubscription(imageId: String, parameters: ImageParameters) {
        self.stream = $property.handleEvents(
            receiveSubscription: { [weak self] _ in
                self?.loadImage(imageId: imageId, parameters: parameters)
            }
        ).eraseToAnyPublisher()
    }
    
    private func loadImage(imageId: String, parameters: ImageParameters) {
        guard property.isNil else { return }
        
        URLResolver()
            .obtainImageURLPublisher(imageId: imageId, parameters)
            .safelyUnwrapOptionals()
            .ignoreFailure()
            .flatMap {
                ImageLoaderObject($0).imagePublisher
            }
            .receive(on: RunLoop.main)
            .sink { [weak self] image in
                self?.property = image
            }
            .store(in: &subscriptions)
    }
}
