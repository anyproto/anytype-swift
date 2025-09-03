import UIKit
import Cache
import Services
import Kingfisher

final class MessageBigBookmarkUIView: UIView {
    
    // MARK: - Private properties
    
    private lazy var hostLabel: UILabel = UILabel()
    private lazy var titleLabel: UILabel = UILabel()
    private lazy var descriptionLabel: UILabel = UILabel()
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    // MARK: - Public properties
    
    var data: MessageBigBookmarkViewData? {
        didSet {
            if data != oldValue {
                updateView()
                updateImage()
            }
        }
    }
    
    var layout: MessageBigBookmarkLayout? {
        didSet {
            if layout != oldValue {
                updateLayout()
                updateImage()
            }
        }
    }
    
    weak var output: (any MessageModuleOutput)?
    
    // MARK: - Pulic
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addTapGesture { [weak self] _ in
            guard let self, let data else { return }
//            output?.didSelectAttachment(messageId: data.messageId, objectId: data.objectId)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return layout?.size ?? .zero
    }
    
    // MARK: - Private
    
    private func updateLayout() {
        hostLabel.addTo(parent: self, frame: layout?.hostFrame)
        titleLabel.addTo(parent: self, frame: layout?.titleFrame)
        descriptionLabel.addTo(parent: self, frame: layout?.descriptionFrame)
        imageView.addTo(parent: self, frame: layout?.imageFrame)
    }
    
    private func updateView() {
        guard let data else { return }
        
        hostLabel.attributedText = data.host
        hostLabel.numberOfLines = data.hostLineLimit
        hostLabel.textColor = data.position.isRight ? .Background.Chat.whiteTransparent : .Control.transparentSecondary
        
        titleLabel.attributedText = data.title
        titleLabel.numberOfLines = data.titleLineLimit
        titleLabel.textColor = data.position.isRight ? .Text.white : .Text.primary
        
        descriptionLabel.attributedText = data.description
        descriptionLabel.numberOfLines = data.descriptionLineLimit
        descriptionLabel.textColor = data.position.isRight ? .Background.Chat.whiteTransparent : .Control.transparentSecondary
        
        imageView.layer.cornerRadius = 2
        imageView.layer.masksToBounds = true
        
        backgroundColor = .Shape.transperentSecondary
        layer.cornerRadius = 12
        layer.masksToBounds = true
    }
    
    private func updateImage() {
        if let layout, let data, data.pictureId.isNotEmpty, let width = layout.imageFrame?.width {
            let url = ImageMetadata(id: data.pictureId, side: .width(width)).contentUrl
            imageView.kf.setImage(with: url)
        } else {
            imageView.kf.cancelDownloadTask()
            imageView.image = nil
        }
    }
}
