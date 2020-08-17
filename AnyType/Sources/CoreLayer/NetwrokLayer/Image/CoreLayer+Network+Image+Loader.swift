//
//  CoreLayer+Network+Image+Loader.swift
//  AnyType
//
//  Created by Denis Batvinkin on 20.08.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Combine
import UIKit
import os

fileprivate typealias Namespace = CoreLayer.Network.Image

private extension Logging.Categories {
    static let coreLayerNetworkingImageLoader: Self = "CoreLayer.Network.Image.Loader"
}

// MARK: - URLResolver
extension Namespace {
    struct URLResolver {
        private let configurationService: ConfigurationServiceProtocol = MiddlewareConfigurationService.init()
        private let subpath = "/image/"
        
        private func imageURL(configuration: MiddlewareConfigurationService.MiddlewareConfiguration, subpath: String) -> URL? {
            let string = configuration.gatewayURL + self.subpath + subpath
            return URL.init(string: string)
        }
                
        func transform(imageId: String) -> AnyPublisher<URL?, Error> {
            self.configurationService.obtainConfiguration().map({self.imageURL(configuration: $0, subpath: imageId)}).eraseToAnyPublisher()
        }
    }
}

// MARK: - Cache
extension Namespace {
    class Cache {
        static let shared: Cache = .init()
        
        private var loaders: NSCache<NSString, Loader> = NSCache()
        
        // Also add disk cache later.
        // For now it is fine.
        private var images: NSCache<NSString, UIImage> = NSCache()
        
        func loaderFor(path: URL) -> Loader {
            let key: NSString = "\(path)" as NSString
            
            if let loader = self.loaders.object(forKey: key) {
                return loader
            } else {
                let loader: Loader = .init(path)
                self.loaders.setObject(loader, forKey: key)
                return loader
            }
        }
        
        func image(url: URL) -> UIImage? {
            guard let image = self.images.object(forKey: "\(url)" as NSString) else {
                return nil
            }
            return image
        }
        func setImage(url: URL, image: UIImage?) {
            guard let image = image else {
                self.images.removeObject(forKey: "\(url)" as NSString)
                return
            }
            self.images.setObject(image, forKey: "\(url)" as NSString)
        }
    }
}

// MARK: - Loader
extension Namespace {
    class Loader: ObservableObject {
        private let imageService: Service = .init()
        private let cache: Cache = .shared
        private var url: URL
        
        private var isLoading: Bool = false
        
        // Publishers
        @Published private var image: UIImage? = nil
        
        // Subscribers
        private var loadImageSubscription: AnyCancellable?
        var imagePublisher: AnyPublisher<UIImage?, Never> = .empty()
        
        // MARK: - Lifecycle
        init(_ url: URL) {
            self.url = url
            self.setup()
        }
        
        func createPublisher() -> AnyPublisher<UIImage?, Never> {
            // Lookup into hash.
            if let image = self.cache.image(url: self.url) {
                return Just(image).eraseToAnyPublisher()
            }
                        
            return self.imageService.fetchImageAndIgnoreError(url: self.url)
                .handleEvents(receiveSubscription: { [weak self] _ in self?.onStart()},
                              receiveOutput: { [weak self] value in self?.onOutput(value)},
                              receiveCompletion: {[weak self] _ in self?.onFinish()},
                              receiveCancel: {[weak self] in self?.onFinish()}).eraseToAnyPublisher()
        }
        
        func setup() {
            self.imagePublisher = self.createPublisher()
        }
        
        func onOutput(_ value: UIImage?) {
            self.cache.setImage(url: self.url, image: value)
        }
        
        func onStart() {
            self.isLoading = true
        }
        
        func onFinish() {
            self.isLoading = false
        }
        
        //    func setup() {
        //        self.imagePublisher = self.$image.handleEvents(receiveSubscription: { [weak self] subscrpition in self?.loadImage() }, receiveCancel: { [weak self] in self?.loadImageSubscription?.cancel() }).eraseToAnyPublisher()
        //    }
        //
        //    init(path: URL) {
        //        self.path = path
        //        self.setup()
        //    }
        //
        //    private func loadImage() {
        //        self.loadImageSubscription = self.imageService.fetchImage(url: self.path).receive(on: RunLoop.main).sink(receiveValue: { [weak self] (value) in
        //            self?.image = value
        //        })
        //    }
    }
    
}
