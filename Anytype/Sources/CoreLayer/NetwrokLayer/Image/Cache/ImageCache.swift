import Combine
import UIKit


private final class EntityKey: NSObject {
    typealias Id = String
    
    private(set) var id: Id
    private(set) var parameters: ImageParameters
    
    internal required init(_ id: Id, _ parameters: ImageParameters) {
        self.id = id
        self.parameters = parameters
        super.init()
    }
    
    static func create(url: URL) -> Self {
//            self.init(url.lastPathComponent)
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let id = url.lastPathComponent
        let parameters: ImageParameters
        if let items = components?.queryItems, let result = try? URLComponentsDecoder().decode(ImageParameters.self, from: items) {
            parameters = result
        }
        else {
            parameters = .init(width: .default)
        }
        return self.init(id, parameters)
    }
    
    static func create(id: Id, _ parameters: ImageParameters) -> Self {
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

class ImageCache {
    private struct Configuration {
        var countLimit: Int = 100
        var totalCostLimit: Int = 1024 * 1024 * 100
    }
    static let shared = ImageCache()
    private var listener: Listener = .init()
    private var configuration: Configuration = .init()
    private var loaders: NSCache<NSString, ImageLoaderObject> = .init()
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
    
    func loaderFor(path: URL) -> ImageLoaderObject {
        let key: NSString = "\(path)" as NSString
        
        if let loader = self.loaders.object(forKey: key) {
            return loader
        } else {
            let loader = ImageLoaderObject(path)
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

extension ImageCache {
    /// We should use `ImageHolder` class that adopts to `NSDiscardableContent`.
    /// Otherwise, `NSCache` will evict all objects on `applicationDidEnterBackground`.
    /// Thanks a lot! https://stackoverflow.com/a/13579963
    private class ImageHolder: NSObject, NSDiscardableContent {
        private(set) var image: UIImage?
        override init() {}
        init(image: UIImage?) {
            self.image = image
        }
        
        private var objectExists: Bool {
            !self.image.isNil
        }
        
        private var accessCounter: Int = 1
        
        func beginContentAccess() -> Bool {
            guard self.objectExists else { return false }
            self.accessCounter += 1
            return true
        }
        
        func endContentAccess() {
            if self.accessCounter > 0 {
                self.accessCounter -= 1
            }
        }
        
        func discardContentIfPossible() {
            if self.accessCounter == 0 {
                self.image = nil
            }
        }
        
        func isContentDiscarded() -> Bool {
            !self.objectExists
        }
    }
}

// MARK: - Publishers
extension ImageCache {
    typealias ImagePublisherReturnType = AnyPublisher<UIImage?, Never>
//    (AnyCancellable?, CurrentValueSubject<UIImage?, Never>)
    private func publisher(key: EntityKey) -> ImagePublisherReturnType {
        Just(self.images.object(forKey: key)?.image).merge(with: self.imagesSubject.filter({$0.key == key}).map(\.value)).eraseToAnyPublisher()
//        let subject = CurrentValueSubject<UIImage?, Never>.init(self.images.object(forKey: key)?.image)
        // we should subscribe on something that will publish updates.
//        let subscription = self.imagesSubject.filter({$0.key == key}).map({$0.value}).subscribe(subject)
//        return (subscription, subject)
    }
    
    func publisher(imageId: String, _ parameters: ImageParameters = .init(width: .default)) -> ImagePublisherReturnType {
        self.publisher(key: .create(id: imageId, parameters))
    }
    
    func publisher(url: URL) -> ImagePublisherReturnType {
        self.publisher(key: .create(url: url))
    }
}
