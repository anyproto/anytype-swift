import Foundation
import Kingfisher
import UIKit
import AnytypeCore

final class AnytypeImageDownloader {
    
    static func retrieveImage(
        with url: URL,
        options: KingfisherOptionsInfo? = nil,
        completionHandler: @escaping (UIImage?) -> Void)
    {
        KingfisherManager.shared.retrieveImage(with: url, options: options) { result in
            switch result {
            case .success(let imageResult):
                completionHandler(imageResult.image)
            case .failure(let error):
                anytypeAssertionFailure(error.localizedDescription)
                completionHandler(nil)
            }
        }
    }
    
    static func retrieveImage(with url: URL) async -> UIImage? {
        await withCheckedContinuation { continuation in
            retrieveImage(with: url) { result in
                continuation.resume(returning: result)
            }
        }
    }
}
