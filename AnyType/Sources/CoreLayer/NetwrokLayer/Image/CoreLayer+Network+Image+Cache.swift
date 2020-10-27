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
    }
}

// MARK: - Cache / Cache
extension Namespace {
    class Cache {
        static let shared: Cache = .init()
                
        private var loaders: NSCache<NSString, Loader> = .init()
        private var imagesSubject: PassthroughSubject<(key: EntityKey, value: UIImage?), Never> = .init()
        // Also add disk cache later.
        // For now it is fine.
        private var images: NSCache<EntityKey, UIImage> = {
            let value: NSCache<EntityKey, UIImage> = .init()
            value.countLimit = 10
            return value
        }()
        
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
            self.images.object(forKey: .create(id: imageId, parameters))
        }
        
        func image(url: URL) -> UIImage? {
            self.images.object(forKey: .create(url: url))
        }
        
        func setImage(url: URL, image: UIImage?) {
            self.imagesSubject.send((.create(url: url), image))
            guard let image = image else {
                self.images.removeObject(forKey: .create(url: url))
                return
            }
            self.images.setObject(image, forKey: .create(url: url))
        }
    }
}

// MARK: - Publishers
extension Namespace.Cache {
    typealias ImageParameters = CoreLayer.Network.Image.ImageParameters
    
    private func publisher(key: EntityKey) -> (AnyCancellable?, CurrentValueSubject<UIImage?, Never>) {
        let subject = CurrentValueSubject<UIImage?, Never>.init(self.images.object(forKey: key))
        /// we should subscribe on something that will publish updates.
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
