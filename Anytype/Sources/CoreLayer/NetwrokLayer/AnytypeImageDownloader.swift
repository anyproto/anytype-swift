import Foundation
import Kingfisher
import UIKit
import AnytypeCore
import Combine

final class AnytypeImageDownloader {
    
    static func retrieveImage(
        with url: URL,
        options: KingfisherOptionsInfo? = nil,
        completionHandler: @escaping (UIImage?, Data?) -> Void)
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
        completionHandler: @escaping (UIImage?, Data?) -> Void)
    {
        let imageMetadata = ImageMetadata(id: imageId, width: .width(width))
        guard let url = imageMetadata.contentUrl else {
            anytypeAssertionFailure("Url is nil")
            completionHandler(nil, nil)
            return
        }
        AnytypeImageDownloader.retrieveImage(with: url, completionHandler: completionHandler)
    }
    
    static func retrieveImage(imageId: String, width: CGFloat) async -> UIImage? {
        let imageMetadata = ImageMetadata(id: imageId, width: .width(width))
        guard let url = imageMetadata.contentUrl else {
            anytypeAssertionFailure("Url is nil")
            return nil
        }
        return await AnytypeImageDownloader.retrieveImage(with: url)
    }
}
