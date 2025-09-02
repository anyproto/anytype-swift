import Foundation
import UIKit

struct MessageBookmarkLayout {
    static let height: CGFloat = 64
}

final class MessageBookmarkUIView: UIView {
    
    private lazy var iconView = IconViewUIKit()
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .caption1Regular
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .uxTitle2Medium
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        
        addTapGesture { [weak self] _ in
            guard let self, let data else { return }
            output?.didSelectAttachment(messageId: data.messageId, objectId: data.objectId)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public properties
    
    var data: MessageBookmarkViewData? {
        didSet {
            if data != oldValue {
                updateView()
            }
        }
    }
    
    weak var output: (any MessageModuleOutput)?
    
    // MARK: - Public
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: MessageBookmarkLayout.height)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let insets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        
        iconView.frame = CGRect(x: insets.left, y: insets.top, width: 14, height: 14)
        titleLabel.frame = CGRect(
            x: iconView.frame.maxX + 6,
            y: 10,
            width: bounds.width - iconView.frame.maxX - 6,
            height: 18
        )
        descriptionLabel.frame = CGRect(
            x: iconView.frame.minX,
            y: titleLabel.frame.maxY + 2,
            width: bounds.width - insets.left - insets.right,
            height: 20
        )
    }
    
    // MARK: - Private
    
    private func updateView() {
        guard let data else { return }
        
        iconView.icon = data.icon
        titleLabel.text = data.title
        titleLabel.textColor = data.style.titleUiColor
        descriptionLabel.text = data.description
        descriptionLabel.textColor = data.style.descriptionUiColor
    }
}
