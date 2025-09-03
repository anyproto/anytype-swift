import Foundation
import UIKit
import Services

final class MessageObjectUIView: UIView {
    
    private lazy var iconView = IconViewUIKit()
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .previewTitle2Medium
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .relation3Regular
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addTapGesture { [weak self] _ in
            guard let self, let data else { return }
            onTap?(data)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public properties
    
    var data: MessageAttachmentDetails? {
        didSet {
            if data != oldValue {
                updateView()
            }
        }
    }
    
    var onTap: ((_ data: MessageAttachmentDetails) -> Void)?
    
    // MARK: - Public
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: MessageObjectLayout.height)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let insets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        
        let container = bounds.inset(by: insets)
        
        iconView.frame = CGRect(x: insets.left, y: insets.top, width: 48, height: 48)
        titleLabel.frame = CGRect(
            x: iconView.frame.maxX + 12,
            y: MessageObjectLayout.height * 0.5 - 21,
            width: container.width - iconView.frame.maxX - 12,
            height: 20
        )
        descriptionLabel.frame = CGRect(
            x: titleLabel.frame.minX,
            y: MessageObjectLayout.height * 0.5 + 1,
            width: titleLabel.frame.width,
            height: 15
        )
    }
    
    // MARK: - Private
    
    private func updateView() {
        guard let data else { return }
        
        iconView.icon = data.objectIconImage
        titleLabel.text = data.title
        titleLabel.textColor = data.style.titleUiColor
        // TODO: move to model
        if let sizeInBytes = data.sizeInBytes, let size = sizeInBytes > 0 ? ByteCountFormatter.fileFormatter.string(fromByteCount: Int64(sizeInBytes)) : nil {
            descriptionLabel.text = "\(data.description) • \(size)"
        } else {
            descriptionLabel.text = data.description
        }
        descriptionLabel.textColor = data.style.descriptionUiColor
    }
}
