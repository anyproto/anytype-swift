import UIKit
import Cache
import Services

final class MessageReplyUIView: UIView {
    
    // MARK: - Private properties
    
    private lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .Control.transparentSecondary
        return label
    }()
    
    private lazy var iconView = IconViewUIKit()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .Control.transparentSecondary
        return label
    }()
    
    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .Shape.transperentPrimary
        view.layer.cornerRadius = 2
        return view
    }()
    
    private let backgroundContainer = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public properties
    
    var data: MessageReplyViewData? {
        didSet {
            if data != oldValue {
                updateData()
            }
        }
    }
    
    var layout: MessageReplyLayout? {
        didSet {
            if layout != oldValue {
                updateLayout()
            }
        }
    }
    
    // MARK: - Pulic
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return layout?.size ?? .zero
    }
    
    // MARK: - Private
    
    private func updateData() {
        guard let data else { return }
        authorLabel.attributedText = data.author
        iconView.icon = data.attachmentIcon
        descriptionLabel.attributedText = data.description
        descriptionLabel.numberOfLines = data.attachmentIcon.isNotNil ? 1 : 3
        
        backgroundContainer.backgroundColor = data.isYour
            ? data.messageYourBackgroundColor.withAlphaComponent(0.5)
            : .Background.Chat.replySomeones
        backgroundContainer.layer.cornerRadius = 16
        backgroundContainer.layer.masksToBounds = true
        lineView.backgroundColor = .Shape.transperentPrimary
        lineView.layer.cornerRadius = 2
        lineView.layer.masksToBounds = true
    }
    
    private func updateLayout() {
        lineView.addTo(parent: self, frame: layout?.lineFrame)
        authorLabel.addTo(parent: self, frame: layout?.authorFrame)
        iconView.addTo(parent: self, frame: layout?.iconFrame)
        descriptionLabel.addTo(parent: self, frame: layout?.descriptionFrame)
        backgroundContainer.addTo(parent: self, frame: layout?.backgroundFrame)
    }
}
