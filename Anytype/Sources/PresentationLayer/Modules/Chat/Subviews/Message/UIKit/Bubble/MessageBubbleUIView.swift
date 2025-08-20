import UIKit
import Cache

final class MessageBubbleUIView: UIView {
    
    // MARK: - Private properties
    
    private lazy var textView = MessageTextUIView()
    private lazy var gridAttachments = MessageGridAttachmentUIViewContainer()
    
    // MARK: - Public properties
    
    var messageText: NSAttributedString? {
        didSet { textView.text = messageText }
    }
    
    var isRight: Bool = false {
        didSet { updateBackgroundColor() }
    }
    
    var messageYourBackgroundColor: UIColor = .white {
        didSet { updateBackgroundColor() }
    }
    
    var layout: MessageBubbleLayout? {
        didSet {
            if layout != oldValue {
                textView.layout = layout?.textLayout
                setNeedsLayout()
            }
        }
    }
    
    // MARK: - Pulic
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 16
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let layout else { return }
        
        if let textFrame = layout.textFrame {
            textView.frame = textFrame
            addSubview(textView)
        } else {
            textView.removeFromSuperview()
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return layout?.bubbleSize ?? .zero
    }
    
    // MARK: - Private

    private func updateBackgroundColor() {
        backgroundColor = isRight ? messageYourBackgroundColor : .Background.Chat.bubbleSomeones
    }
}
