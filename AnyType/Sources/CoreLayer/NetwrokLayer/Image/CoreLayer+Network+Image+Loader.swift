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
import URLComponentsCoder

fileprivate typealias Namespace = CoreLayer.Network.Image

private extension Logging.Categories {
    static let coreLayerNetworkingImageLoader: Self = "CoreLayer.Network.Image.Loader"
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
        
        private func createPublisher() -> AnyPublisher<UIImage?, Never> {
            // Lookup into hash.
            if let image = self.cache.image(url: self.url) {
                return Just(image).eraseToAnyPublisher()
            }
            let url = self.url
            return self.imageService.fetchImageAndIgnoreError(url: self.url)
                .handleEvents(receiveSubscription: { [weak self] _ in self?.onStart()},
                              receiveOutput: { value in
                                Cache.shared.setImage(url: url, image: value)
//                                self.onOutput(value)
                              },
                              receiveCompletion: {[weak self] _ in self?.onFinish()},
                              receiveCancel: {[weak self] in self?.onFinish()}).eraseToAnyPublisher()
        }
        
        private func setup() {
            self.imagePublisher = self.createPublisher()
        }
        
        private func onOutput(_ value: UIImage?) {
            self.cache.setImage(url: self.url, image: value)
        }
        
        private func onStart() {
            self.isLoading = true
        }
        
        private func onFinish() {
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

