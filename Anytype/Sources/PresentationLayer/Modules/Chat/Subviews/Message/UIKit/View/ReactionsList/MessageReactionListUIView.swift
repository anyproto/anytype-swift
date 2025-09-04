import UIKit
import AnytypeCore

final class MessageReactionListUIView: UIView {
    
    // MARK: - Private properties
    
    private var cache = [MessageReactionUIView]()
    private var views = [MessageReactionUIView]()
    
    private lazy var addReactionView = {
        let view = UIImageView()
        view.image = UIImage(asset: .X24.reaction)
        view.tintColor = .Control.primary
        view.backgroundColor = .Shape.transperentSecondary
        view.addTapGesture { [weak self] _ in
            guard let self, let data = self.data else { return }
            onTapAddReaction?(data)
        }
        return view
    }()
    
    // MARK: - Public properties
    
    var data: MessageReactionListData? {
        didSet {
            if data != oldValue {
                updateData()
            }
        }
    }
    
    var layout: MessageReactionListLayout? {
        didSet {
            if layout != oldValue {
                updateLayout()
                setNeedsLayout()
            }
        }
    }
    
    var onTapReaction: ((_ emoji: String) -> Void)?
    var onLongTapReaction: ((_ reaction: MessageReactionData) -> Void)?
    var onTapAddReaction: ((_ reactions: MessageReactionListData) -> Void)?
    
    // MARK: - Pulic
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return layout?.size ?? .zero
    }
    
    // MARK: - Private
    
    private func updateData() {
        guard let data else {
            views.forEach { $0.removeFromSuperview() }
            views.removeAll()
            return
        }
        
        let reactions = data.reactions
        
        var cachedForLayout = cache
        
        views.removeAll()
        
        for reaction in reactions {
            let subview = cachedForLayout.popLast() ?? {
                let view = MessageReactionUIView()
                view.onTapReaction = { [weak self] emoji in
                    self?.onTapReaction?(emoji)
                }
                view.onLongTapReaction = { [weak self] data in
                    self?.onLongTapReaction?(data)
                }
                // Sync position with popLast operation
                cache.insert(view, at: 0)
                return view
            }()
            
            subview.data = reaction
            views.append(subview)
            addSubview(subview)
        }
        
        cachedForLayout.forEach { $0.removeFromSuperview() }
        
        updateLayout()
    }
    
    private func updateLayout() {
        guard let layout, layout.reactionLayouts.count == views.count else { return }
        
        for (index, layout) in layout.reactionLayouts.enumerated() {
            let subview = views[safe: index]
            subview?.layout = layout
        }
        
        for (index, frame) in layout.reactionFrames.enumerated() {
            let subview = views[safe: index]
            subview?.frame = frame
        }
        
        if let addReactionFrame = layout.addReactionFrame {
            addSubview(addReactionView)
            addReactionView.frame = addReactionFrame
            addReactionView.layer.cornerRadius = addReactionFrame.width * 0.5
        } else {
            addReactionView.removeFromSuperview()
        }
    }
}
