import Foundation
import UIKit

final class ImageStorage: ImageStorageProtocol, @unchecked Sendable {
    
    static let shared = ImageStorage()
    
    private init() {}
    
    private let lock = NSLock()
    private let cache = NSCache<NSString, UIImage>()
    
    func image(forKey key: String) -> UIImage? {
        lock.lock()
        defer { lock.unlock() }
        return cache.object(forKey: key as NSString)
    }
    
    func saveImage(_ image: UIImage, forKey key: String) {
        lock.lock()
        defer { lock.unlock() }
        cache.setObject(image, forKey: key as NSString)
    }
}
