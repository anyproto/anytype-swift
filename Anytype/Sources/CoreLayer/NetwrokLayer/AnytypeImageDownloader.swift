import Foundation
import Kingfisher
import UIKit
import AnytypeCore
import Combine

struct AnytypeImageDownloaderResult {
    private let result: RetrieveImageResult
    
    init(result: RetrieveImageResult) {
        self.result = result
    }
    
    var image: UIImage {
        result.image
    }
    
    func data() -> Data? {
        result.data()
    }
}

final class AnytypeImageDownloader {
    
    static func retrieveImage(
        with url: URL,
        options: KingfisherOptionsInfo? = nil,
        completionHandler: @escaping @Sendable (UIImage?, Data?) -> Void)
    {
        KingfisherManager.shared.retrieveImage(with: url, options: options) { result in
            switch result {
            case .success(let imageResult):
                completionHandler(imageResult.image, imageResult.data())
            case .failure(let error):
                if !error.isInvalidResponseStatusCode(404) {
                    anytypeAssertionFailure(error.localizedDescription)
                }
                completionHandler(nil, nil)
            }
        }
    }
    
    static func retrieveImage(with url: URL, options: KingfisherOptionsInfo? = nil) async -> AnytypeImageDownloaderResult? {
        do {
            let result = try await KingfisherManager.shared.retrieveImage(with: .network(url), options: options)
            return AnytypeImageDownloaderResult(result: result)
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
        return await AnytypeImageDownloader.retrieveImage(with: url)?.image
    }
}
