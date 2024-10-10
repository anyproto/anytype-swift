import Foundation
import Cache
import UIKit
import AVKit

protocol VideoPreviewStorageProtocol {
    func preview(url: URL, size: CGSize) async throws -> UIImage
}

final class VideoPreviewStorage: VideoPreviewStorageProtocol {
    
    private struct StorageKey: Hashable {
        let url: URL
        let size: CGSize
    }
    
    private let storage: Storage<StorageKey, UIImage>?
    
    private let operationsQueue = DispatchQueue(label: "VideoPreviewQueue")
    
    init() {
        let diskConfig = DiskConfig(name: "VideoPreviewCache", maxSize: 30 * 1024 * 1024) // 30 Mb
        let memoryConfig = MemoryConfig(expiry: .never, countLimit: 100, totalCostLimit: 300)

        self.storage = try? Storage(
          diskConfig: diskConfig,
          memoryConfig: memoryConfig,
          fileManager: FileManager.default,
          transformer: TransformerFactory.forImage()
        )
    }
    
    func preview(url: URL, size: CGSize) async throws -> UIImage {
        return try await withCheckedThrowingContinuation { continuation in
            loadPreviewInQueue(url: url, size: size) { result in
                switch result {
                case .success(let success):
                    continuation.resume(returning: success)
                case .failure(let failure):
                    continuation.resume(throwing: failure)
                }
            }
        }
    }

    private func loadPreviewInQueue(url: URL, size: CGSize, completion: @escaping (Result<UIImage, any Error>) -> Void) {
        
        let key = StorageKey(url: url, size: size)
        
        operationsQueue.async { [weak self] in
            
            guard let self else {
                completion(.failure(CommonError.undefined))
                return
            }
            
            if let image = try? storage?.object(forKey: key) {
                completion(.success(image))
                return
            }
            
            guard let image = UIImage(videoPreview: url, size: size) else {
                completion(.failure(CommonError.undefined))
                return
            }
            
            try? storage?.setObject(image, forKey: key)
            completion(.success(image))
        }
    }
}

fileprivate extension UIImage {
    
    convenience init?(videoPreview path: URL?, size: CGSize) {
        guard let path else { return nil }
        do {
            let asset = AVURLAsset(url: path, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            imgGenerator.maximumSize = size
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            self.init(cgImage: cgImage)
        } catch {
            return nil
        }
    }
}
