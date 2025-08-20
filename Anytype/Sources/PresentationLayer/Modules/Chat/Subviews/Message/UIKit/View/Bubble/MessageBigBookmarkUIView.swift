import UIKit
import Cache
import Services

struct MessageBigBookmarkViewData: Equatable {
    let host: NSAttributedString
    let title: NSAttributedString
    let description: NSAttributedString
    let pictureId: String
    let position: MessageHorizontalPosition
    
    let hostLineLimit = 1
    let titleLineLimit = 1
    let descriptionLineLimit = 2
}

extension MessageBigBookmarkViewData {
    init(details: ObjectDetails, position: MessageHorizontalPosition) {
        self.host = NSAttributedString(
            string: details.source?.url.host() ?? "",
            attributes: [.font: UIFont.relation3Regular]
        )
        self.title = NSAttributedString(
            string: details.name,
            attributes: [.font: UIFont.previewTitle2Medium]
        )
        self.description = NSAttributedString(
            string: details.name,
            attributes: [.font: UIFont.relation3Regular]
        )
        self.pictureId = details.picture
        self.position = position
    }
}

final class MessageBigBookmarkUIView: UIView {
    
    // MARK: - Private properties
    
    private lazy var hostLabel: UILabel = UILabel()
    private lazy var titleLabel: UILabel = UILabel()
    private lazy var descriptionLabel: UILabel = UILabel()
    
    // MARK: - Public properties
    
    var data: MessageBigBookmarkViewData? {
        didSet {
            if data != oldValue {
                updateView()
            }
        }
    }
    
    var layout: MessageBigBookmarkLayout? {
        didSet {
            if layout != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    // MARK: - Pulic
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let layout else { return }
        
        hostLabel.frame = layout.hostFrame ?? .zero
        titleLabel.frame = layout.titleFrame ?? .zero
        descriptionLabel.frame = layout.descriptionFrame ?? .zero
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return layout?.size ?? .zero
    }
    
    // MARK: - Private
    
    private func updateView() {
        guard let data else { return }
        
        if data.host.string.isNotEmpty {
            addSubview(hostLabel)
            hostLabel.attributedText = data.host
            hostLabel.numberOfLines = data.hostLineLimit
            hostLabel.textColor = data.position.isRight ? .Background.Chat.whiteTransparent : .Control.transparentSecondary
        } else {
            hostLabel.removeFromSuperview()
        }
        
        if data.title.string.isNotEmpty {
            addSubview(titleLabel)
            titleLabel.attributedText = data.title
            titleLabel.numberOfLines = data.titleLineLimit
            titleLabel.textColor = data.position.isRight ? .Text.white : .Text.primary
        } else {
            titleLabel.removeFromSuperview()
        }
        
        if data.description.string.isNotEmpty {
            addSubview(descriptionLabel)
            descriptionLabel.attributedText = data.description
            descriptionLabel.numberOfLines = data.descriptionLineLimit
            descriptionLabel.textColor = data.position.isRight ? .Background.Chat.whiteTransparent : .Control.transparentSecondary
        } else {
            descriptionLabel.removeFromSuperview()
        }
    }
}
