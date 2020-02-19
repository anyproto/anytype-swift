//
//  ImageLoader.swift
//  AnyType
//
//  Created by Denis Batvinkin on 20.08.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Combine
import UIKit


/// Image cashe
class ImageLoaderCache {
    static let shared = ImageLoaderCache()
    
    var loaders: NSCache<NSString, ImageLoader> = NSCache()
    
    func loaderFor(path: URL) -> ImageLoader {
        let key = NSString(string: "\(path)")
        
        if let loader = loaders.object(forKey: key) {
            return loader
        } else {
            let loader = ImageLoader(path: path)
            loaders.setObject(loader, forKey: key)
            return loader
        }
    }
}


/// Image loader
final class ImageLoader: ObservableObject {
    private var imageService = ImageService()
    private let path: URL
    
    // Publishers
    @Published var image: UIImage? = nil
    // Workaround for initialization
    var objectWillChange: AnyPublisher<UIImage?, Never> = Publishers.Sequence<[UIImage?], Never>(sequence: []).eraseToAnyPublisher()
    
    // Subscribers
    var cancellable: AnyCancellable?
    
    // MARK: - Lifecylce
    
    deinit {
        cancellable?.cancel()
    }
    
    init(path: URL) {
        self.path = path
        
        // load the data once SwiftUI starts subscribing to the image object
        self.objectWillChange = $image.handleEvents(receiveSubscription: { [weak self] sub in
                self?.loadImage()
            }, receiveCancel: { [weak self] in
                self?.cancellable?.cancel()
        }).eraseToAnyPublisher()
    }
    
    // MARK: - Private methods
    
    // NOTE:
    // Memory leak here.
    // `.assign` will retain `self`.
    private func loadImage() {
        cancellable = imageService.fetchImage(url: path)
            .receive(on: DispatchQueue.main)
            .assign(to: \ImageLoader.image, on: self)
    }
    
}

