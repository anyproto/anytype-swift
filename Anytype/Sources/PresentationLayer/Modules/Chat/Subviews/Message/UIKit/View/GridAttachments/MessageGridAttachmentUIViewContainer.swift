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
    
    weak var output: (any MessageModuleOutput)? {
        didSet {
            cachedImages.forEach { $0.output = output }
            cachedVideos.forEach { $0.output = output }
        }
    }
    
    // MARK: - Pulic
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 12
        layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
                    view.layer.cornerRadius = 4
                    view.layer.masksToBounds = true
                    view.output = output
                    // Sync position with popLast operation
                    cachedVideos.insert(view, at: 0)
                    return view
                }()
                
                videoView.data = MessageVideoViewData(messageId: "", details: object)
                views.append(videoView)
                addSubview(videoView)
            default:
                let imageView = cachedImagesForLayout.popLast() ?? {
                    let view = MessageImageUIView()
                    view.layer.cornerRadius = 4
                    view.layer.masksToBounds = true
                    view.output = output
                    // Sync position with popLast operation
                    cachedImages.insert(view, at: 0)
                    return view
                }()
                
                imageView.data = MessageImageViewData(messageId: "", details: object)
                views.append(imageView)
                addSubview(imageView)
            }
        }
        
        cachedVideosForLayout.forEach { $0.removeFromSuperview() }
        cachedImagesForLayout.forEach { $0.removeFromSuperview() }
    }
}
