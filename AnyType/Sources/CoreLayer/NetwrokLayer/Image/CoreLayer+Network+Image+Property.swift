import Combine
import UIKit
import os

fileprivate typealias Namespace = CoreLayer.Network.Image

// MARK: - Property
extension Namespace {
    class Property {
        private var internalSubscription: AnyCancellable?
        private var externalSubscription: AnyCancellable?
        private var loadingSubscription: AnyCancellable?
        @Published var property: UIImage?
        var stream: AnyPublisher<UIImage?, Never> = .empty()
        private var imageId: String
        private var parameters: ImageParameters
        init(imageId: String, _ parameters: ImageParameters = .init(width: .default), _ cache: Cache = .shared) {
            self.imageId = imageId
            self.parameters = parameters
            let publisher = cache.publisher(imageId: imageId, parameters)
//          self.externalSubscription = publisher.0
//          self.internalSubscription = publisher.1
            self.internalSubscription = publisher
                .sink(receiveValue: { [weak self] (value) in
                self?.property = value
            })
            self.setup()
        }
        
        func setup() {
            self.stream = self.$property.handleEvents(receiveSubscription: {[weak self] _ in self?.loading()}).eraseToAnyPublisher()
        }
        
        func loading() {
            if self.property == nil {
                // start loading
                self.loadingSubscription = Namespace.URLResolver.init().transform(imageId: self.imageId, self.parameters).safelyUnwrapOptionals().ignoreFailure().flatMap({
                    Namespace.Loader.init($0).imagePublisher
                }).receive(on: RunLoop.main).sink { _ in }
            }
        }
    }
}
