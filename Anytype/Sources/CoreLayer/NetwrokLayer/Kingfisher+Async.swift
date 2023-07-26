import Foundation
import Kingfisher

// Source https://github.com/onevcat/Kingfisher/issues/1864
extension KingfisherManager {
    /**
    - Throws: `KingfisherError`
    */
    @discardableResult
    func retrieveImageAsync(
        with resource: Resource,
        options: KingfisherOptionsInfo? = nil,
        progressBlock: DownloadProgressBlock? = nil
    ) async throws -> RetrieveImageResult {
        var downloadTask: DownloadTask?

        return try await withTaskCancellationHandler {
            // Needed because Kingfisher can in some cases incorrectly call the completion handler multiple times.
            var hasBeenCalled = false

            return try await withCheckedThrowingContinuation { continuation in
                downloadTask = retrieveImage(
                    with: resource,
                    options: options,
                    progressBlock: progressBlock
                ) { result in
                    guard !hasBeenCalled else {
                        return
                    }

                    continuation.resume(with: result)
                    hasBeenCalled = true
                }
            }
        } onCancel: { [downloadTask] in
            downloadTask?.cancel()
        }
    }
}

extension KingfisherWrapper where Base: KFCrossPlatformImageView {
    /**
    - Throws: `KingfisherError`
    */
    @discardableResult
    func setImageAsync(
        with resource: Resource?,
        placeholder: Placeholder? = nil,
        options: KingfisherOptionsInfo? = nil,
        progressBlock: DownloadProgressBlock? = nil
    ) async throws -> RetrieveImageResult {
        var downloadTask: DownloadTask?

        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                downloadTask = setImage(
                    with: resource,
                    placeholder: placeholder,
                    options: options,
                    progressBlock: progressBlock,
                    completionHandler: continuation.resume(with:)
                )
            }
        } onCancel: { [downloadTask] in
            downloadTask?.cancel()
        }
    }
}
