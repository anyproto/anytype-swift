import Foundation
import Kingfisher
import UIKit
import AnytypeCore
import Combine
import os.signpost

final class AnytypeImageDownloader {
    
    static func retrieveImage(
        with url: URL,
        options: KingfisherOptionsInfo? = nil,
        completionHandler: @escaping @Sendable (UIImage?, Data?) -> Void)
    {
//        KingfisherManager.shared.cache.clearCache()
//        
//        let log = OSLog(subsystem: "anytype", category: .pointsOfInterest)
//        let signpostID = OSSignpostID(log: log)
//        os_signpost(.begin, log: log, name: "download_image_kingfisher", signpostID: signpostID)
//
//        let start = CFAbsoluteTimeGetCurrent()
//        KingfisherManager.shared.retrieveImage(with: url, options: options) { result in
//            let time = Int(((CFAbsoluteTimeGetCurrent() - start) * 1_000)) // milliseconds
//            print("Kingfisher Time: \(time) ms")
//            os_signpost(.end, log: log, name: "download_image_kingfisher", signpostID: signpostID)
//            switch result {
//            case .success(let imageResult):
//                completionHandler(imageResult.image, imageResult.data())
//            case .failure(let error):
//                if !error.isInvalidResponseStatusCode(404) {
//                    anytypeAssertionFailure(error.localizedDescription)
//                }
//                completionHandler(nil, nil)
//            }
//        }
        
////        let start = CFAbsoluteTimeGetCurrent() // 200-250 верхняя картинка
        Task {
            do {
                let log = OSLog(subsystem: "anytype", category: .pointsOfInterest)
                let signpostID = OSSignpostID(log: log)
                os_signpost(.begin, log: log, name: "download_image_url_session", signpostID: signpostID)
                
                let (image, data) = try await ImageLoader.shared.loadImage(from: url)
//                let time = Int(((CFAbsoluteTimeGetCurrent() - start) * 1_000)) // milliseconds
//                print("URL session Time: \(time) ms")
                
                os_signpost(.end, log: log, name: "download_image_url_session", signpostID: signpostID)
                completionHandler(image, data)
                
            } catch {
                print("Error loading image: \(error.localizedDescription)")
            }
        }
    }
    
    static func retrieveImage(with url: URL) async -> UIImage? {
        do {
            return try await KingfisherManager.shared.retrieveImage(with: .network(url)).image
        } catch is CancellationError {
            return nil
        } catch let error as KingfisherError where error.isInvalidResponseStatusCode(404) {
            return nil
        } catch {
            anytypeAssertionFailure(error.localizedDescription)
            return nil
        }
    }
}

extension AnytypeImageDownloader {
    static func retrieveImage(
        imageId: String,
        width: CGFloat,
        options: KingfisherOptionsInfo? = nil,
        completionHandler: @escaping @Sendable (UIImage?, Data?) -> Void)
    {
        let imageMetadata = ImageMetadata(id: imageId, side: .width(width))
        guard let url = imageMetadata.contentUrl else {
            anytypeAssertionFailure("Url is nil")
            completionHandler(nil, nil)
            return
        }
        AnytypeImageDownloader.retrieveImage(with: url, completionHandler: completionHandler)
    }
    
    static func retrieveImage(imageId: String, width: CGFloat) async -> UIImage? {
        let imageMetadata = ImageMetadata(id: imageId, side: .width(width))
        guard let url = imageMetadata.contentUrl else {
            anytypeAssertionFailure("Url is nil")
            return nil
        }
        return await AnytypeImageDownloader.retrieveImage(with: url)
    }
}

actor ImageCache {
    private var cache = NSCache<NSString, UIImage>()
    
    func image(for key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    func insertImage(_ image: UIImage, for key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
    
    func removeImage(for key: String) {
        cache.removeObject(forKey: key as NSString)
    }
    
    func removeAllImages() {
        cache.removeAllObjects()
    }
}

class ImageLoader {
    static let shared = ImageLoader()
    private let cache = ImageCache()
    
    private init() {}
    
    func loadImage(from url: URL) async throws -> (UIImage, Data?) {
        
        let start = CFAbsoluteTimeGetCurrent() //
        
        // Check cache first
        if let cachedImage = await cache.image(for: url.absoluteString) {
//            return cachedImage
        }
        
        // Download the image
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        guard let image = UIImage(data: data) else {
            throw NSError(domain: "ImageLoader", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "Invalid image data"])
        }
        
        // Store in cache
        await cache.insertImage(image, for: url.absoluteString)
        
        let time = Int(((CFAbsoluteTimeGetCurrent() - start) * 1_000)) // milliseconds
        print("URL session Time: \(time) ms")
        
        return (image, data)
    }
}
