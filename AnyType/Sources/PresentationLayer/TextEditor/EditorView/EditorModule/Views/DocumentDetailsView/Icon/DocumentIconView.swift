import UIKit

final class DocumentIconView: UIView {
    
    // MARK: - Views
    
    private let activityIndicatorView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.color = .grayscale10
        indicator.backgroundColor = UIColor(white: 0.0, alpha: 0.32)
        indicator.isHidden = true
        
        return indicator
    }()
    
    private let containerView = UIView()
    private let iconEmojiView = DocumentIconEmojiView()
    private let iconImageView = DocumentIconImageView()
    
    // MARK: - Variables
    
    private var heightConstraint: NSLayoutConstraint!
    
    private var borderConstraintX: NSLayoutConstraint!
    private var borderConstraintY: NSLayoutConstraint!
    
    private lazy var menuInteraction = UIContextMenuInteraction(delegate: self)
    private var menuActionHandler: ((DocumentIconViewUserAction) -> Void)?
    
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
        
        viewModel.onMediaPickerImageSelect = { [weak self] in
            self?.showLoader()
        }
        
        menuActionHandler = { action in
            viewModel.handleIconUserAction(action)
        }
    }
    
    private func configureEmptyState() {
        containerView.removeInteraction(menuInteraction)
        menuActionHandler = nil
        
        heightConstraint.constant = 0
        borderConstraintY.constant = 0
        borderConstraintX.constant = 0
        
        hideLoader()
        iconEmojiView.isHidden = true
        iconImageView.isHidden = true
    }
    
    private func configureStateBaseOnIcon(_ icon: DocumentIcon, _ isBorderVisible: Bool) {
        hideLoader()
        
        let height: CGFloat
        let cornerRadius: CGFloat
        
        switch icon {
        case let .emoji(iconEmoji):
            height = Constants.Emoji.height
            cornerRadius = iconEmojiView.layer.cornerRadius
            
            iconEmojiView.configure(model: iconEmoji)
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
        
        containerView.addInteraction(menuInteraction)
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
    
    private func showLoader() {
        let animation = CATransition()
        animation.type = .fade;
        animation.duration = 0.3;
        activityIndicatorView.layer.add(animation, forKey: nil)
        
        activityIndicatorView.startAnimating()
        activityIndicatorView.isHidden = false
    }
    
    private func hideLoader() {
        activityIndicatorView.stopAnimating()
        activityIndicatorView.isHidden = true
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

// MARK: - UIContextMenuInteractionDelegate

extension DocumentIconView: UIContextMenuInteractionDelegate {

    var isMenuInteractionEnabled: Bool {
        activityIndicatorView.isHidden
    }
    
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard isMenuInteractionEnabled else { return nil }
        
        let actions = DocumentIconViewUserAction.allCases.map { action -> UIAction in
            let menuAction = UIAction(
                title: action.title,
                image: action.icon
            ) { [weak self ] _ in
                self?.menuActionHandler?(action)
            }
            
            if action == .remove {
                menuAction.attributes = .destructive
            }
            
            return menuAction
        }
        
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil,
            actionProvider: { suggestedActions in
                UIMenu(
                    title: "",
                    children: actions
                )
            }
        )
    }

    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        previewForHighlightingMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        let targetView: UIView = {
            if !iconEmojiView.isHidden {
                return iconEmojiView
            }
            
            if !iconImageView.isHidden {
                return iconImageView
            }
            
            return containerView
        }()
        
        let parameters = UIPreviewParameters()
        
        parameters.visiblePath = UIBezierPath(
            roundedRect: targetView.bounds,
            cornerRadius: targetView.layer.cornerRadius
        )
        
        return UITargetedPreview(view: targetView, parameters: parameters)
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
