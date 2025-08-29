import UIKit
import Cache

final class MessageUIView: UIView, UIContentView {
    
    private static let calculator = MessageLayoutCalculator()
    
    private lazy var iconView = IconViewUIKit()
    private lazy var bubbleView = MessageBubbleUIView()
    private lazy var reactionsView = MessageReactionListUIView()
    private lazy var replyView = MessageReplyUIView()
    
    private var data: MessageViewData {
        didSet {
            if data != oldValue {
                layout = nil
                setNeedsLayout()
            }
        }
    }
    private var layout: MessageLayout?
    
    var configuration: any UIContentConfiguration {
        didSet {
            guard let configuration = configuration as? MessageConfiguration else { return }
            if data != configuration.model {
                data = configuration.model
            }
        }
    }
    
    init(configuration: MessageConfiguration) {
        self.configuration = configuration
        self.data = configuration.model
        super.init(frame:.zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        updateLayoutIfNeeded(targetSize: size)
        return layout?.cellSize ?? .zero
    }
    
    override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        updateLayoutIfNeeded(targetSize: targetSize)
        return layout?.cellSize ?? .zero
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayoutIfNeeded(targetSize: bounds.size)
    
        guard let layout else { return }
        
        // TODO: Split setup data and layout
        if let bubbleFrame = layout.bubbleFrame {
            bubbleView.data = MessageBubbleViewData(data: data)
            bubbleView.frame = bubbleFrame
            bubbleView.layout = layout.bubbleLayout
            addSubview(bubbleView)
        } else {
            bubbleView.removeFromSuperview()
        }
        
        if let iconFrame = layout.iconFrame {
            iconView.icon = data.authorIcon
            iconView.frame = iconFrame
            addSubview(iconView)
        } else {
            iconView.removeFromSuperview()
        }
        
        if let reactionsFrame = layout.reactionsFrame {
            reactionsView.frame = reactionsFrame
            reactionsView.layout = layout.reactionsLayout
            reactionsView.data = MessageReactionListData(data: data)
            addSubview(reactionsView)
        } else {
            reactionsView.removeFromSuperview()
        }
        
        if let replyFrame = layout.replyFrame, let reply = data.replyModel {
            replyView.frame = replyFrame
            replyView.layout = layout.replyLayout
            replyView.data = MessageReplyViewData(model: reply)
            addSubview(replyView)
        } else {
            replyView.removeFromSuperview()
        }
    }
    
    // MARK: - Private
    
    private func setupView() {
//        addSubview(iconView)
//        addSubview(bubbleView)
    }
    
    private func updateLayoutIfNeeded(targetSize: CGSize) {
        guard layout == nil else { return }
        
        layout = Self.calculator.makeLayout(targetSize: targetSize, data: data)
    }
}
