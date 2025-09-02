import UIKit
import AnytypeCore

final class MessageReactionListUIView: UIView {
    
    // MARK: - Private properties
    
    private var cache = [MessageReactionUIView]()
    private var views = [MessageReactionUIView]()
    
    private lazy var addReactionView = UIView()
    
    // MARK: - Public properties
    
    var data: MessageReactionListData? {
        didSet {
            if data != oldValue {
                updateView()
            }
        }
    }
    
    var layout: MessageReactionListLayout? {
        didSet {
            if layout != oldValue {
                updateLayoutForReactions()
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
        
        for (index, frame) in layout.reactionFrames.enumerated() {
            let subview = views[safe: index]
            subview?.frame = frame
        }
        
        addReactionView.frame = layout.addReactionFrame ?? .zero
    }
    
    // MARK: - Private
    
    private func updateView() {
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
                // Sync position with popLast operation
                cache.insert(view, at: 0)
                return view
            }()
            
            subview.data = reaction
            views.append(subview)
            addSubview(subview)
        }
        
        cachedForLayout.forEach { $0.removeFromSuperview() }
        
        if data.canAddReaction {
            addReactionView.backgroundColor = .red
            addSubview(addReactionView)
        } else {
            addReactionView.removeFromSuperview()
        }
        
        updateLayoutForReactions()
    }
    
    private func updateLayoutForReactions() {
        guard let layout, layout.reactionLayouts.count == views.count else { return }
        
        for (index, layout) in layout.reactionLayouts.enumerated() {
            let subview = views[safe: index]
            subview?.layout = layout
        }
    }
}
