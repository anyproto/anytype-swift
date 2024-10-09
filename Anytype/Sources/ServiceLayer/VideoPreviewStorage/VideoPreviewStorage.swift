import Foundation
import Cache
import UIKit
import AVKit

protocol VideoPreviewStorageProtocol {
    func preview(url: URL) async -> UIImage?
}

actor VideoPreviewStorage: VideoPreviewStorageProtocol {
    
    private let storage: Storage<URL, UIImage>?
    
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
    
    func preview(url: URL) async -> UIImage? {
        if let image = try? storage?.object(forKey: url) {
            return image
        }
        
        let task: Task<UIImage?, Never> = Task {
            guard let image = UIImage(videoPreview: url) else { return nil }
            try? storage?.setObject(image, forKey: url)
            return image
        }
        
        return await task.value
    }
}

fileprivate extension UIImage {
    
    convenience init?(videoPreview path: URL?) {
        guard let path else { return nil }
        do {
            let asset = AVURLAsset(url: path, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            self.init(cgImage: cgImage)
        } catch {
            return nil
        }
    }
}
