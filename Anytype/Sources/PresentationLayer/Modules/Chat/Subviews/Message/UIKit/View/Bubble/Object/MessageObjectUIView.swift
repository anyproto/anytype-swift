import Foundation
import UIKit
import Services

struct MessageObjectViewData: Equatable {
    let icon: Icon
    let title: String
    let description: String
    let style: MessageAttachmentStyle
    let size: String?
    let syncStatus: SyncStatus?
    let syncError: SyncError?
}

extension MessageObjectViewData {
    init(
        details: MessageAttachmentDetails,
        position: MessageHorizontalPosition
    ) {
        let sizeInBytes = Int64(details.sizeInBytes ?? 0)
        let size = sizeInBytes > 0 ? ByteCountFormatter.fileFormatter.string(fromByteCount: sizeInBytes) : nil
        
        self.icon = details.objectIconImage
        self.title = details.title
        self.description = details.description
        self.style = position.isRight ? .messageYour : .messageOther
        self.size = size
        self.syncStatus = details.syncStatus
        self.syncError = details.syncError
    }
}


struct MessageObjectLayout {
    static let height: CGFloat = 64
}

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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public properties
    
    var data: MessageObjectViewData? {
        didSet {
            if data != oldValue {
                updateView()
            }
        }
    }
    
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
        
        iconView.icon = data.icon
        titleLabel.text = data.title
        titleLabel.textColor = data.style.titleUiColor
        if let size = data.size {
            descriptionLabel.text = "\(data.description) • \(size)"
        } else {
            descriptionLabel.text = data.description
        }
        descriptionLabel.textColor = data.style.descriptionUiColor
    }
}
