import UIKit
import BlocksModels

final class DocumentIconView: UIView {
    
    // MARK: - Views
    
    private let activityIndicatorView = ActivityIndicatorView()
    
    private let containerView = UIView()
    private let iconEmojiView = DocumentIconEmojiView()
    private let iconImageView = DocumentIconImageView()
    
    // MARK: - Variables
    
    private var heightConstraint: NSLayoutConstraint!
    
    private var borderConstraintX: NSLayoutConstraint!
    private var borderConstraintY: NSLayoutConstraint!
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupView()
    }
       
}

// MARK: - ConfigurableView

extension DocumentIconView: ConfigurableView {

    func configure(model: DocumentIconViewState) {
        switch model {
        case let .icon(icon):
            configureIconState(icon)
        case let .preview(preview):
            configurePreviewState(preview)
        case .empty:
            configureEmptyState()
        }
    }
    
    private func configureIconState(_ icon: DocumentIconType) {
        activityIndicatorView.hide()

        switch icon {
        case let .basic(basic):
            configureBasicIcon(basic)
        case let .profile(profile):
            configureProfileIcon(profile)
        }
    }
    
    private func configureBasicIcon(_ basicIcon: DocumentIconType.Basic) {
        switch basicIcon {
        case let .emoji(emoji):
            showEmojiView(emoji)
        case let .imageId(imageId):
            showImageView(.basic(.imageId(imageId)))
        }
    }
    
    private func configureProfileIcon(_ profileIcon: DocumentIconType.Profile) {
        switch profileIcon {
        case let .imageId(imageId):
            showImageView(.profile(.imageId(imageId)))
        case let .placeholder(character):
            showImageView(.profile(.placeholder(character)))
        }
    }
    
    private func showEmojiView(_ emoji: IconEmoji) {
        iconEmojiView.configure(model: emoji.value)
        
//        heightConstraint.constant = iconEmojiView.height
        
        let cornerRadius = iconEmojiView.layer.cornerRadius
        containerView.layer.cornerRadius = cornerRadius
        configureBorder(cornerRadius: cornerRadius)
        
        iconEmojiView.isHidden = false
        iconImageView.isHidden = true
    }
    
    private func showImageView(_ model: DocumentIconImageView.Model) {
        iconImageView.configure(model: model)
        
//        heightConstraint.constant = iconImageView.height
        
        let cornerRadius = iconImageView.layer.cornerRadius
        containerView.layer.cornerRadius = cornerRadius
        configureBorder(cornerRadius: cornerRadius)
        
        iconEmojiView.isHidden = true
        iconImageView.isHidden = false
    }
    
    private func configurePreviewState(_ preview: DocumentIconViewPreviewType) {
        switch preview {
        case let .basic(image):
            showImageView(.basic(.preview(image)))
        case let .profile(image):
            showImageView(.profile(.preview(image)))
        }
        
        let animation = CATransition()
        animation.type = .fade;
        animation.duration = 0.3;
        activityIndicatorView.layer.add(animation, forKey: nil)
        
        activityIndicatorView.show()
    }
    
    private func configureEmptyState() {
        activityIndicatorView.hide()
        
        heightConstraint.constant = 0
        
        borderConstraintY.constant = 0
        borderConstraintX.constant = 0
        
        iconEmojiView.isHidden = true
        iconImageView.isHidden = true
    }
    
    private func configureBorder(cornerRadius: CGFloat) {
        borderConstraintX.constant = Constants.borderWidth
        borderConstraintY.constant = Constants.borderWidth
        
        layer.cornerRadius = cornerRadius + Constants.borderWidth
    }
    
}

// MARK: - Private extension

private extension DocumentIconView {
    
    func setupView() {
        containerView.clipsToBounds = true
        
        backgroundColor = .grayscaleWhite
        
        setupLayout()
    }
    
    func setupLayout() {
        addSubview(containerView) {
            $0.center(in: self)
            
            $0.width.equal(to: $0.height)
            
            heightConstraint = $0.height.equal(to: 0)
            
            borderConstraintX = $0.leading.equal(to: leadingAnchor)
            borderConstraintY = $0.top.equal(to: topAnchor)
        }
        
        containerView.addSubview(iconEmojiView) {
            $0.pinToSuperview()
        }
        
        containerView.addSubview(iconImageView) {
            $0.pinToSuperview()
        }
        
        containerView.addSubview(activityIndicatorView) {
            $0.pinToSuperview()
        }
    }
    
}

private extension DocumentIconView {
    
    enum Constants {
        static let borderWidth: CGFloat = 4
    }
    
}

private extension DetailsLayout {
    
    var isProfile: Bool {
        guard case .profile = self else {
            return false
        }
        
        return true
    }
    
}
