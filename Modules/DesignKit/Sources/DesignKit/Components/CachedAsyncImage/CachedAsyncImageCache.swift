import Cache
import Foundation
import UIKit

public actor CachedAsyncImageCache {
    
    public static let `default` = CachedAsyncImageCache(cacheSize: 500 * 1024 * 1024, cacheFolder: "CachedAsyncImageCacheDefault") // 500 Mb
    
    private let storage: Storage<String, UIImage>?
    private var activeTasks: [String: Task<UIImage, Error>] = [:]
    
    public init(cacheSize: UInt, cacheFolder: String) {
        let diskConfig = DiskConfig(name: cacheFolder, expiry: .seconds(30 * 24 * 60 * 60), maxSize: cacheSize) // 30 Days
        let memoryConfig = MemoryConfig(expiry: .never, countLimit: 50, totalCostLimit: 50 * 1024 * 1024) // 50 Mb
        self.storage = try? Storage<String, UIImage>(diskConfig: diskConfig, memoryConfig: memoryConfig, fileManager: .default, transformer: TransformerFactory.forImage())
    }
    
    public func loadImage(from url: URL) async throws -> Image {
        let key = url.absoluteString
        if let task = activeTasks[key] {
            return try await task.value
        }
        
        guard let storage else { throw CachedAsyncImageCacheError.storageNotCreated }
        
        if let cachedData = try? storage.object(forKey: key) {
            return cachedData
        }
        
        let task = Task { () -> UIImage in
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else {
                throw CachedAsyncImageCacheError.imageNotCreated
            }
            try storage.setObject(image, forKey: key)
            return image
        }
        activeTasks[key] = task
        defer { activeTasks.removeValue(forKey: key) }
        return try await task.value
    }
    
    nonisolated public func prefetchImages(_ urls: [URL]) {
        for url in urls {
            Task {
                _ = try await loadImage(from: url)
            }
        }
    }
    
    nonisolated func cachedImage(from url: URL) throws -> Image {
        guard let storage else { throw CachedAsyncImageCacheError.storageNotCreated }
        let key = url.absoluteString
        return try storage.object(forKey: key)
    }
}

enum CachedAsyncImageCacheError: Error {
    case imageNotCreated
    case storageNotCreated
}

extension Storage: @unchecked @retroactive Sendable {}
