import UIKit
import AnytypeCore

final class MessageGridAttachmentUIViewContainer: UIView {
    
    private struct CacheKey: Hashable {
        let count: Int
        let targetSize: CGSize
    }
    
    private struct CacheValue: Hashable {
        let frames: [CGRect]
        let size: CGSize
    }
    
    @MainActor
    private enum Cache {
        // TODO: Use NSCache
        static var cache: [CacheKey: CacheValue] = [:]
    }
    
    private enum Constants {
        static let spacing: CGFloat = 4
    }
    
    private var cachedImages = [MessageImageUIView]()
    private var cachedVideos = [MessageVideoUIView]()
    
    var objects: [MessageAttachmentDetails] = [] {
        didSet {
            if objects != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        updateFramesIfNeeded(size: size)
        let key = CacheKey(count: objects.count, targetSize: size)
        return Cache.cache[key]?.size ?? .zero
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateFramesIfNeeded(size: frame.size)
        
        let key = CacheKey(count: objects.count, targetSize: frame.size)
        let frames = Cache.cache[key]?.frames ?? []
        
        if frames.count != objects.count {
            anytypeAssertionFailure("Frames should be the same count as objects")
            return
        }
        
        var cachedImagesForLayout = cachedImages
        var cachedVideosForLayout = cachedVideos
        
        for (index, frame) in frames.enumerated() {
            guard let object = objects[safe: index] else { return }
            
            switch object.resolvedLayoutValue {
            case .video:
                let videoView = cachedVideosForLayout.popLast() ?? {
                    let view = MessageVideoUIView()
                    // Sync position with popLast operation
                    cachedVideos.insert(view, at: 0)
                    return view
                }()
                
                if videoView.superview.isNil {
                    addSubview(videoView)
                }
                
                videoView.frame = frame
                videoView.setDetails(object)
            default:
                let imageView = cachedImagesForLayout.popLast() ?? {
                    let view = MessageImageUIView()
                    // Sync position with popLast operation
                    cachedImages.insert(view, at: 0)
                    return view
                }()
                
                if imageView.superview.isNil {
                    addSubview(imageView)
                }
                
                imageView.frame = frame
                imageView.setDetails(object)
            }
        }
        
        cachedVideosForLayout.forEach { $0.removeFromSuperview() }
        cachedImagesForLayout.forEach { $0.removeFromSuperview() }
    }
    
    private func updateFramesIfNeeded(size: CGSize) {
        let key = CacheKey(count: objects.count, targetSize: size)
        
        guard Cache.cache[key].isNil else { return }
        
        var frames: [CGRect] = []
        
        let width = size.width
        
        var height: CGFloat = 0
        let rowsCountByLine = MessageAttachmentsGridLayoutBuilder.makeGridRows(countItems: objects.count)
        
        for (index, rowItems) in rowsCountByLine.enumerated() {
            let rowHeight = (width - (rowItems - 1) * Constants.spacing) / CGFloat(rowItems)
            
            var frameX: CGFloat = 0
            
            for _ in 0..<rowItems {
                let frame = CGRect(
                    x: frameX,
                    y: height,
                    width: rowHeight,
                    height: rowHeight
                )
                frames.append(frame)
                frameX += rowHeight + Constants.spacing
            }
            
            if index == (rowsCountByLine.count - 1) {
                height += rowHeight
            } else {
                height += (rowHeight + Constants.spacing)
            }
        }
        
        let calculatedSize = CGSize(width: width, height: height)
        
        Cache.cache[key] = CacheValue(frames: frames, size: calculatedSize)
        
        if size != calculatedSize {
            let key = CacheKey(count: objects.count, targetSize: calculatedSize)
            Cache.cache[key] = CacheValue(frames: frames, size: calculatedSize)
        }
    }
}
