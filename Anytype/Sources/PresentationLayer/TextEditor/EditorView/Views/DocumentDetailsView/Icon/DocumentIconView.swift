import UIKit

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
        case let .preview(image):
            configurePreviewState(image)
        case .empty:
            configureEmptyState()
        }
    }
    
    private func configureIconState(_ icon: DocumentIcon) {
        activityIndicatorView.hide()
        
        let height: CGFloat
        let cornerRadius: CGFloat
        
        switch icon {
        case let .emoji(iconEmoji):
            height = Constants.Emoji.height
            cornerRadius = iconEmojiView.layer.cornerRadius
            
            iconEmojiView.configure(model: iconEmoji.value)
            showEmojiView()
        case let .imageId(imageId):
            height = Constants.Image.height
            cornerRadius = iconImageView.layer.cornerRadius
            
            iconImageView.configure(model: .imageId(imageId))
            showImageView()
        }
        
        heightConstraint.constant = height
        containerView.layer.cornerRadius = cornerRadius
        
        configureBorder(cornerRadius: cornerRadius)
    }
    
    private func configurePreviewState(_ image: UIImage?) {
        heightConstraint.constant = Constants.Image.height
        containerView.layer.cornerRadius = iconImageView.layer.cornerRadius
        
        configureBorder(cornerRadius: containerView.layer.cornerRadius)
        
        iconImageView.configure(model: .image(image))
        showImageView()
        
        let animation = CATransition()
        animation.type = .fade;
        animation.duration = 0.3;
        activityIndicatorView.layer.add(animation, forKey: nil)
        
        activityIndicatorView.show()
    }
    
    private func configureEmptyState() {
        heightConstraint.constant = 0
        borderConstraintY.constant = 0
        borderConstraintX.constant = 0
        
        activityIndicatorView.hide()
        iconEmojiView.isHidden = true
        iconImageView.isHidden = true
    }
    
    private func showEmojiView() {
        iconEmojiView.isHidden = false
        iconImageView.isHidden = true
    }
    
    private func showImageView() {
        iconEmojiView.isHidden = true
        iconImageView.isHidden = false
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
        
        enum Emoji {
            static let height: CGFloat = 96
        }
        
        enum Image {
            static let height: CGFloat = 122
        }
    }
}
