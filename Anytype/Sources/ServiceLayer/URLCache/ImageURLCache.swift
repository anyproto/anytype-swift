import Foundation

extension URLCache {
    
    static let anytypeImages: URLCache = {
        let memoryCapacity = 50 * 1024 * 1024    // 50 MB
        let diskCapacity   = 1000 * 1024 * 1024   // 1000 MB
        return URLCache(
            memoryCapacity: memoryCapacity,
            diskCapacity: diskCapacity,
            diskPath: "imagesCacheAnytype"
        )
    }()
}
