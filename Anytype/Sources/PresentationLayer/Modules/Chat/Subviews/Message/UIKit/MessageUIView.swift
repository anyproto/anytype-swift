import UIKit
import Cache

final class MessageUIView: UIView, UIContentView {
    
    private static let calculator = MessageLayoutCalculator()
    
    private lazy var iconView = IconViewUIKit()
    private lazy var bubbleView = MessageBubbleUIView()
    
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
        
        if let bubbleFrame = layout.bubbleFrame {
            bubbleView.messageText = NSAttributedString(data.messageString)
            bubbleView.isRight = data.position.isRight
            bubbleView.frame = bubbleFrame
            bubbleView.isHidden = false
            bubbleView.layout = layout.bubbleLayout
        } else {
            bubbleView.isHidden = true
        }
        
        if let iconFrame = layout.iconFrame {
            iconView.icon = data.authorIcon
            iconView.frame = iconFrame
            iconView.isHidden = false
        } else {
            iconView.isHidden = true
        }
    }
    
    // MARK: - Private
    
    private func setupView() {
        addSubview(iconView)
        addSubview(bubbleView)
    }
    
    private func updateLayoutIfNeeded(targetSize: CGSize) {
        guard layout == nil else { return }
        
        layout = Self.calculator.makeLayout(targetSize: targetSize, data: data)
    }
}
