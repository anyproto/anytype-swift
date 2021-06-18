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
    
    struct ConfigurationModel {
        let viewModel: DocumentIconViewModel
        let isBorderVisible: Bool
    }
    
    func configure(model: ConfigurationModel?) {
        guard let model = model else {
            configureEmptyState()
            return
        }
        
        let viewModel = model.viewModel
        
        configureStateBaseOnIcon(viewModel.documentIcon, model.isBorderVisible)
        
        viewModel.onMediaPickerImageSelect = { [weak self] image in
            self?.showLoader(with: image)
        }
    }
    
    private func configureEmptyState() {
        heightConstraint.constant = 0
        borderConstraintY.constant = 0
        borderConstraintX.constant = 0
        
        activityIndicatorView.hide()
        iconEmojiView.isHidden = true
        iconImageView.isHidden = true
    }
    
    private func configureStateBaseOnIcon(_ icon: DocumentIcon, _ isBorderVisible: Bool) {
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
            
            iconImageView.configure(model: imageId)
            showImageView()
        }
        
        heightConstraint.constant = height
        containerView.layer.cornerRadius = cornerRadius
        
        configureBorder(
            isVisible: isBorderVisible,
            cornerRadius: cornerRadius
        )
    }
    
    private func configureBorder(isVisible: Bool, cornerRadius: CGFloat) {
        if isVisible {
            borderConstraintX.constant = Constants.borderWidth
            borderConstraintY.constant = Constants.borderWidth
            layer.cornerRadius = cornerRadius + Constants.borderWidth

        } else {
            borderConstraintX.constant = 0
            borderConstraintY.constant = 0
            layer.cornerRadius = cornerRadius
        }
    }
    
    private func showLoader(with image: UIImage) {
        let animation = CATransition()
        animation.type = .fade;
        animation.duration = 0.3;
        activityIndicatorView.layer.add(animation, forKey: nil)
        
        activityIndicatorView.show(with: image)
    }
    
    private func showEmojiView() {
        iconEmojiView.isHidden = false
        iconImageView.isHidden = true
    }
    
    private func showImageView() {
        iconEmojiView.isHidden = true
        iconImageView.isHidden = false
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
