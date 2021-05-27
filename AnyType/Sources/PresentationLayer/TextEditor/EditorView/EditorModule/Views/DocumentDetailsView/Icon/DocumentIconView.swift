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
    
    private let iconEmojiView = DocumentIconEmojiView()
    private let iconImageView = DocumentIconImageView()
    
    // MARK: - Variables
    
    private var heightConstraint: NSLayoutConstraint!
    
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
    
    func configure(model: DocumentIconViewModel?) {
        guard let model = model else {
            configureEmptyState()
            return
        }
        
        configureStateBaseOnIcon(model.documentIcon)
        
        model.onMediaPickerImageSelect = { [weak self] imagePath in
            self?.showLoaderWithImage(at: imagePath)
        }
        
        menuActionHandler = { action in
            model.handleIconUserAction(action)
        }
        
        addInteraction(menuInteraction)
    }
    
    private func configureEmptyState() {
        removeInteraction(menuInteraction)
        heightConstraint.constant = 0
        menuActionHandler = nil
        
        hideLoader()
        
        iconEmojiView.isHidden = true
        iconImageView.isHidden = true
    }
    
    private func configureStateBaseOnIcon(_ icon: DocumentIcon) {
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
        activityIndicatorView.layer.cornerRadius = cornerRadius
        heightConstraint.constant = height
    }
    
    private func showLoaderWithImage(at _: String) {
        // TODO: show image preview
        activityIndicatorView.startAnimating()
        
        let animation = CATransition()
        animation.type = .fade;
        animation.duration = 0.3;
        activityIndicatorView.layer.add(animation, forKey: nil)
        
        activityIndicatorView.isHidden = false
    }
    
    func hideLoader() {
        activityIndicatorView.stopAnimating()
        activityIndicatorView.isHidden = true
    }
    
    func showEmojiView() {
        iconEmojiView.isHidden = false
        iconImageView.isHidden = true
    }
    
    func showImageView() {
        iconEmojiView.isHidden = true
        iconImageView.isHidden = false
    }
    
}

// MARK: - Private extension

private extension DocumentIconView {
    
    func setupView() {
        setupLayout()
    }
    
    func setupLayout() {
        addSubview(iconEmojiView) {
            $0.pinToSuperview()
        }
        
        addSubview(iconImageView) {
            $0.pinToSuperview()
        }
        
        addSubview(activityIndicatorView) {
            $0.pinToSuperview()
        }
        
        layoutUsing.anchors {
            $0.width.equal(to: heightAnchor)
            
            heightConstraint = $0.height.equal(to: 0)
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
        
        let actions = DocumentIconViewUserAction.allCases.map { action in
            UIAction(
                title: action.title,
                image: action.icon
            ) { [weak self ] _ in
                self?.menuActionHandler?(action)
            }
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
            
            return self
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
        enum Emoji {
            static let cornerRadius: CGFloat = 20
            static let height: CGFloat = 96
        }
        
        enum Image {
            static let cornerRadius: CGFloat = 22
            static let height: CGFloat = 122
        }
    }
}
