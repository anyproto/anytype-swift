import Foundation
import Cache
import UIKit
import AVKit

protocol VideoPreviewStorageProtocol: Sendable {
    nonisolated func cache(url: URL, size: CGSize) throws-> UIImage
    func preview(url: URL, size: CGSize) async throws -> UIImage
}

actor VideoPreviewStorage: VideoPreviewStorageProtocol {
    
    private struct StorageKey: Hashable {
        let url: URL
        let size: CGSize
    }
    
    private var taskCache = [StorageKey: Task<UIImage, any Error>]()
    private let storage: Storage<StorageKey, UIImage>?
    
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
    
    nonisolated func cache(url: URL, size: CGSize) throws-> UIImage {
        guard let storage else { throw CommonError.undefined }
        let key = StorageKey(url: url, size: size)
        return try storage.object(forKey: key)
    }
    
    func preview(url: URL, size: CGSize) async throws -> UIImage {
        
        let key = StorageKey(url: url, size: size)
        
        if let task = taskCache[key] {
            return try await task.value
        }
        
        if let image = try? storage?.object(forKey: key) {
            return image
        }

        let task = Task {
            return try UIImage(videoPreview: url, size: size)
        }

        taskCache[key] = task

        do {
            let image = try await task.value
            try? storage?.setObject(image, forKey: key)
            return image
        } catch {
            taskCache[key] = nil
            throw error
        }
    }
}

fileprivate extension UIImage {
    
    convenience init(videoPreview path: URL, size: CGSize) throws {
        let asset = AVURLAsset(url: path, options: nil)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        imgGenerator.appliesPreferredTrackTransform = true
        imgGenerator.maximumSize = size
        let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
        self.init(cgImage: cgImage)
    }
}
