//
//  CoreLayer+Network+Image+Cache.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 26.10.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Combine
import UIKit
import URLComponentsCoder

fileprivate typealias Namespace = CoreLayer.Network.Image

// MARK: - ImageParameters
extension Namespace {
    struct ImageParameters: Codable, Hashable {
        internal init(width: CoreLayer.Network.Image.ImageParameters.Width) {
            self.width = width
        }
        
        ///`Write Decoder (?)`
        struct Width: Codable, Hashable {
            let value: Int
            static let `default`: Self = .init(value: 1080)
            static let `thumbnail`: Self = .init(value: 100)
        }
        
        let width: Width
        
        enum CodingKeys: String, CodingKey {
            case width = "width"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let width = try container.decode(Int.self, forKey: .width)
            self.width = .init(value: width)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.width.value, forKey: .width)
        }
    }
}

// MARK: - Cache / EntityKey
extension Namespace.Cache {
    private final class EntityKey: NSObject {
        typealias Id = String
        typealias Parameters = Namespace.ImageParameters
        private(set) var id: Id
        private(set) var parameters: Parameters
        internal required init(_ id: Id, _ parameters: Parameters) {
            self.id = id
            self.parameters = parameters
            super.init()
        }
        static func create(url: URL) -> Self {
//            self.init(url.lastPathComponent)
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            let id = url.lastPathComponent
            let parameters: Parameters
            if let items = components?.queryItems, let result = try? URLComponentsCoder.TopLevel.AliasesMap.Decoder.init().decode(Parameters.self, from: items) {
                parameters = result
            }
            else {
                parameters = .init(width: .default)
            }
            return self.init(id, parameters)
        }
        static func create(id: Id, _ parameters: Parameters) -> Self {
            self.init(id, parameters)
        }
        override func isEqual(_ object: Any?) -> Bool {
            guard let other = object as? Self else { return false }
            return other.id == self.id && other.parameters == self.parameters
        }
        override var hash: Int {
            self.id.hash ^ self.parameters.hashValue
        }
        override var debugDescription: String {
            return "\(self.id) -> \(self.parameters)"
        }
    }
}

// MARK: - Cache / Cache
extension Namespace {
    class Cache {
        private struct Configuration {
            var countLimit: Int = 100
            var totalCostLimit: Int = 1024 * 1024 * 100
        }
        static let shared: Cache = .init()
        private var listener: Listener = .init()
        private var configuration: Configuration = .init()
        private var loaders: NSCache<NSString, Loader> = .init()
        private var imagesSubject: PassthroughSubject<(key: EntityKey, value: UIImage?), Never> = .init()
        // Also add disk cache later.
        // For now it is fine.
        private var images: NSCache<EntityKey, ImageHolder> = .init()
        class Listener: NSObject, NSCacheDelegate {
            override init() {}
            func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
                print("object: \(obj)")
            }
        }
        init() {
            self.images.countLimit = self.configuration.countLimit
            self.images.totalCostLimit = self.configuration.totalCostLimit
            self.images.delegate = self.listener
        }
        
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
        
        func image(imageId: String, _ parameters: ImageParameters = .init(width: .default)) -> UIImage? {
            self.images.object(forKey: .create(id: imageId, parameters))?.image
        }
        
        func image(url: URL) -> UIImage? {
            self.images.object(forKey: .create(url: url))?.image
        }
        
        func setImage(url: URL, image: UIImage?) {
            self.imagesSubject.send((.create(url: url), image))
            guard let image = image else {
                self.images.removeObject(forKey: .create(url: url))
                return
            }
            self.images.setObject(.init(image: image), forKey: .create(url: url))
        }
    }
}

extension Namespace.Cache {
    /// We should use `ImageHolder` class that adopts to `NSDiscardableContent`.
    /// Otherwise, `NSCache` will evict all objects on `applicationDidEnterBackground`.
    /// Thanks a lot! https://stackoverflow.com/a/13579963
    private class ImageHolder: NSObject, NSDiscardableContent {
        var image: UIImage?
        override init() {}
        init(image: UIImage?) {
            self.image = image
        }
        
        private var accessCounter: Bool = true
        
        func beginContentAccess() -> Bool {
            self.accessCounter = self.image != nil
            return self.accessCounter
        }
        
        func endContentAccess() {
            self.accessCounter = false
        }
        
        func discardContentIfPossible() {
            self.image = nil
        }
        
        func isContentDiscarded() -> Bool {
            self.image == nil
        }
    }
}

// MARK: - Publishers
extension Namespace.Cache {
    typealias ImageParameters = CoreLayer.Network.Image.ImageParameters
    
    private func publisher(key: EntityKey) -> (AnyCancellable?, CurrentValueSubject<UIImage?, Never>) {
        let subject = CurrentValueSubject<UIImage?, Never>.init(self.images.object(forKey: key)?.image)
        /// we should subscribe on something that will publish updates.
        print("entityKey: \(key.debugDescription) has image: \(String(describing: subject.value))")
        let subscription = self.imagesSubject.filter({$0.key == key}).map({$0.value}).subscribe(subject)
        return (subscription, subject)
    }
    
    func publisher(imageId: String, _ parameters: ImageParameters = .init(width: .default)) -> (AnyCancellable?, CurrentValueSubject<UIImage?, Never>) {
        self.publisher(key: .create(id: imageId, parameters))
    }
    
    func publisher(url: URL) -> (AnyCancellable?, CurrentValueSubject<UIImage?, Never>) {
        self.publisher(key: .create(url: url))
    }
}
