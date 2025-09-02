import UIKit
import AnytypeCore

final class MessageReactionUIView: UIView {
    
    // MARK: - Private properties
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var iconView = IconViewUIKit()
    
    // MARK: - Public properties
    
    var data: MessageReactionData? {
        didSet {
            if data != oldValue {
                updateView()
            }
        }
    }
    
    var layout: MessageReactionLayout? {
        didSet {
            if layout != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    // MARK: - Pulic
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(emojiLabel)
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
        
        emojiLabel.frame = layout.emojiFrame
        countLabel.frame = layout.countFrame ?? .zero
        iconView.frame = layout.iconFrme ?? .zero
    }
    
    // MARK: - Private
    
    private func updateView() {
        guard let data else { return }
        
        emojiLabel.attributedText = data.emojiAttributedString
        switch data.content {
        case .count(let count):
            countLabel.attributedText = data.countAttributedString
            addSubview(countLabel)
            iconView.removeFromSuperview()
        case .icon(let icon):
            iconView.icon = icon
            addSubview(iconView)
            countLabel.removeFromSuperview()
        }
        countLabel.textColor = data.selected ? .Text.white : .Text.primary
        
        
        backgroundColor = data.selected ? data.messageYourBackgroundColor : UIColor.Background.Chat.bubbleSomeones
        layer.cornerRadius = MessageReactionLayout.height * 0.5
        layer.masksToBounds = true
    }
}
