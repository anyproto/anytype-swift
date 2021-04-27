import Combine
import UIKit
import os


class ImageProperty {
    @Published var property: UIImage?
    var stream: AnyPublisher<UIImage?, Never> = .empty()
    
    private var internalSubscription: AnyCancellable?
    private var loadingSubscription: AnyCancellable?
    
    private var imageId: String
    private var parameters: ImageParameters
    
    init(imageId: String, _ parameters: ImageParameters = .init(width: .default), _ cache: ImageCache = .shared) {
        self.imageId = imageId
        self.parameters = parameters
        let publisher = cache.publisher(imageId: imageId, parameters)
//          self.internalSubscription = publisher.1
        self.internalSubscription = publisher
            .sink(receiveValue: { [weak self] (value) in
            self?.property = value
        })
        self.setup()
    }
    
    private func setup() {
        self.stream = self.$property.handleEvents(receiveSubscription: { [weak self] _ in self?.loading()}).eraseToAnyPublisher()
    }
    
    private func loading() {
        if self.property == nil {
            // start loading
            self.loadingSubscription = URLResolver.init().obtainImageURLPublisher(imageId: self.imageId, self.parameters).safelyUnwrapOptionals().ignoreFailure().flatMap({
                ImageLoaderObject($0).imagePublisher
            }).receive(on: DispatchQueue.main).sink { _ in }
        }
    }
}
