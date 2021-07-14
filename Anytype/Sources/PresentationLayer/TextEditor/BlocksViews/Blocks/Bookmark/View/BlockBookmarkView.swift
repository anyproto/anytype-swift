import Combine
import UIKit
import BlocksModels
    
final class BlockBookmarkView: UIView {
    /// Views
    private var contentView = UIView()
    private var titleView: UILabel!
    private var descriptionView: UILabel!
    private var iconView: UIImageView!
    private var urlView: UILabel!
    
    private var leftStackView: UIStackView!
    private var urlStackView: UIStackView!
    
    private var imageView: UIImageView!
    
    private var imageViewWidthConstraint: NSLayoutConstraint?
    private var imageViewHeightConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUIElements()
        addLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    func setupUIElements() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.leftStackView = {
            let view = UIStackView()
            view.axis = .vertical
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        self.urlStackView = {
            let view = UIStackView()
            view.axis = .horizontal
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()

        self.titleView = {
            let view = UILabel()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.font = UIFont.captionMediumFont
            view.textColor = .grayscale90
            return view
        }()
        
        self.descriptionView = {
            let view = UILabel()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.numberOfLines = 3
            view.lineBreakMode = .byWordWrapping
            view.font = .captionFont
            view.textColor = .grayscale70
            return view
        }()
        
        self.iconView = {
            let view = UIImageView()
            view.contentMode = .scaleAspectFit
            view.clipsToBounds = true
            view.heightAnchor.constraint(equalToConstant: Layout.iconHeight).isActive = true
            view.widthAnchor.constraint(equalToConstant: Layout.iconHeight).isActive = true
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()

        self.urlView = {
            let view = UILabel()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.font = .captionFont
            view.textColor = .grayscale90
            return view
        }()
        
        self.imageView = {
            let view = UIImageView()
            view.contentMode = .scaleAspectFit
            view.clipsToBounds = true
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        urlStackView.addArrangedSubview(iconView)
        urlStackView.addArrangedSubview(urlView)
        
        leftStackView.addArrangedSubview(titleView)
        leftStackView.addArrangedSubview(descriptionView)
        leftStackView.addArrangedSubview(urlStackView)
        
        contentView.addSubview(leftStackView)
        contentView.addSubview(imageView)
        
        addSubview(contentView)
        
        leftStackView.backgroundColor = .white
        imageView.backgroundColor = .white
    }
    
    /// Layout
    func addLayout() {
        contentView.edgesToSuperview()

        if let view = leftStackView, let superview = view.superview {
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: Layout.commonInsets.left),
                view.trailingAnchor.constraint(lessThanOrEqualTo: superview.trailingAnchor, constant: -Layout.commonInsets.right),
                view.topAnchor.constraint(equalTo: superview.topAnchor, constant: Layout.commonInsets.top),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -Layout.commonInsets.bottom)
            ])
        }
    }
    
    func addLayoutForImageView() {
        if let view = self.imageView, let superview = view.superview, let leftView = self.leftStackView {
            self.imageViewWidthConstraint = view.widthAnchor.constraint(equalTo: superview.widthAnchor, multiplier: Layout.imageSizeFactor)
            self.imageViewWidthConstraint?.isActive = true
            
            self.imageViewHeightConstraint = view.heightAnchor.constraint(equalToConstant: Layout.imageHeightConstant)
            self.imageViewHeightConstraint?.isActive = true
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: leftView.trailingAnchor, constant: Layout.commonInsets.left),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                view.topAnchor.constraint(greaterThanOrEqualTo: superview.topAnchor),
                view.bottomAnchor.constraint(lessThanOrEqualTo: superview.bottomAnchor)
            ])
        }
    }
    
    func updateIcon(icon: UIImage) {
        iconView.image = icon
    }
    
    func updateImage(image: UIImage) {
        imageView.image = image
    }
    
    /// Configurations
    func handle(state: BlockBookmarkState) {
        switch state {
        case let .onlyURL(payload):
            urlView.text = payload.url
            titleView.isHidden = true
            descriptionView.isHidden = true
            urlView.isHidden = false
            iconView.isHidden = true
            urlStackView.isHidden = false
        case let .fetched(payload):
            titleView.text = payload.title
            descriptionView.text = payload.subtitle
            urlView.text = payload.url
            if payload.hasImage {
                addLayoutForImageView()   
            }
            titleView.isHidden = false
            descriptionView.isHidden = false
            urlView.isHidden = false
            iconView.isHidden = self.iconView.image == nil
            urlStackView.isHidden = false
        default:
            titleView.isHidden = true
            descriptionView.isHidden = true
            urlView.isHidden = true
            iconView.isHidden = true
            urlStackView.isHidden = true
        }
    }
}

private extension BlockBookmarkView {
    enum Layout {
        static let commonInsets: UIEdgeInsets = .init(top: 16, left: 16, bottom: 16, right: 16)
        static let spacing: CGFloat = 5
        static let imageSizeFactor: CGFloat = 1 / 3
        static let imageHeightConstant: CGFloat = 150
        static let iconHeight: CGFloat = 24
    }
}

