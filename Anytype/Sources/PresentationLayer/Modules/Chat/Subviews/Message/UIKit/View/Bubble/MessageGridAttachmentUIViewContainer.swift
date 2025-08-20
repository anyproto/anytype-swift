import UIKit
import AnytypeCore

final class MessageGridAttachmentUIViewContainer: UIView {
    
    // MARK: - Private properties
    
    private var cachedImages = [MessageImageUIView]()
    private var cachedVideos = [MessageVideoUIView]()
    private var views = [UIView]()
    
    // MARK: - Public properties
    
    var objects: [MessageAttachmentDetails] = [] {
        didSet {
            if objects != oldValue {
                updateView()
            }
        }
    }
    
    var layout: MessageGridAttachmentsContainerLayout? {
        didSet {
            if layout != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    // MARK: - Pulic
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return layout?.size ?? .zero
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let layout else { return }
        
        for (index, frame) in layout.objectFrames.enumerated() {
            let subview = views[safe: index]
            subview?.frame = frame
        }
    }
    
    // MARK: - Private
    
    private func updateView() {
        
        var cachedImagesForLayout = cachedImages
        var cachedVideosForLayout = cachedVideos
        
        views.removeAll()
        
        for object in objects {
            switch object.resolvedLayoutValue {
            case .video:
                let videoView = cachedVideosForLayout.popLast() ?? {
                    let view = MessageVideoUIView()
                    // Sync position with popLast operation
                    cachedVideos.insert(view, at: 0)
                    return view
                }()
                
                videoView.setDetails(object)
                views.append(videoView)
                addSubview(videoView)
            default:
                let imageView = cachedImagesForLayout.popLast() ?? {
                    let view = MessageImageUIView()
                    // Sync position with popLast operation
                    cachedImages.insert(view, at: 0)
                    return view
                }()
                imageView.setDetails(object)
                views.append(imageView)
                addSubview(imageView)
            }
        }
        
        cachedVideosForLayout.forEach { $0.removeFromSuperview() }
        cachedImagesForLayout.forEach { $0.removeFromSuperview() }
    }
}
