import UIKit
import AnytypeCore

// TODO: Add placeholder state for details.downloadingState
final class MessageListAttachmentsUIView: UIView {
    
    // MARK: - Private properties
    
    private var cachedBookmarks = [MessageBookmarkUIView]()
    private var cachedAttachments = [MessageObjectUIView]()
    private var views = [UIView]()
    
    // MARK: - Public properties
    
    var data: MessageListAttachmentsViewData? {
        didSet {
            if data != oldValue {
                updateView()
            }
        }
    }
    
    var layout: MessageListAttachmentsLayout? {
        didSet {
            if layout != oldValue {
                updateLayout()
            }
        }
    }
    
    weak var output: (any MessageModuleOutput)? {
        didSet {
            cachedBookmarks.forEach { $0.output = output }
            cachedAttachments.forEach { $0.output = output }
        }
    }
    
    // MARK: - Pulic
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return layout?.size ?? .zero
    }
    
    // MARK: - Private
    
    private func updateLayout() {
        
        guard let layout else { return }
        
        for (index, frame) in layout.objectFrames.enumerated() {
            let subview = views[safe: index]
            subview?.frame = frame
        }
    }
    
    private func updateView() {
        guard let data else {
            views.forEach { $0.removeFromSuperview() }
            views.removeAll()
            return
        }
        
        let objects = data.objects
        
        var cachedBookmarksForLayout = cachedBookmarks
        var cachedAttachmentsForLayout = cachedAttachments
        
        views.removeAll()
        
        for object in objects {
            switch object.resolvedLayoutValue {
            case .bookmark:
                let subview = cachedBookmarksForLayout.popLast() ?? {
                    let view = MessageBookmarkUIView()
                    view.backgroundColor = .Shape.transperentSecondary
                    view.layer.cornerRadius = 12
                    view.layer.masksToBounds = true
                    view.output = output
                    // Sync position with popLast operation
                    cachedBookmarks.insert(view, at: 0)
                    return view
                }()
                
                subview.data = MessageBookmarkViewData(details: object, position: data.position)
                views.append(subview)
                addSubview(subview)
            default:
                let subview = cachedAttachmentsForLayout.popLast() ?? {
                    let view = MessageObjectUIView()
                    view.backgroundColor = .Shape.transperentSecondary
                    view.layer.cornerRadius = 12
                    view.layer.masksToBounds = true
                    view.output = output
                    // Sync position with popLast operation
                    cachedAttachments.insert(view, at: 0)
                    return view
                }()
                
                subview.data = MessageObjectViewData(details: object, position: data.position)
                views.append(subview)
                addSubview(subview)
            }
        }
        
        cachedBookmarksForLayout.forEach { $0.removeFromSuperview() }
        cachedAttachmentsForLayout.forEach { $0.removeFromSuperview() }
    }
}
