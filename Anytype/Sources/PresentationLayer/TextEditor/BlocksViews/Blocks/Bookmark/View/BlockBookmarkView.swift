import Combine
import UIKit
import BlocksModels
    
final class BlockBookmarkView: UIView {
    /// Variables
    private let style: Style = .presentation
    
    /// Publishers
    private var subscription: AnyCancellable?
    private var resourceStream: AnyPublisher<BlockBookmarkResource?, Never> = .empty()
    @Published var resource: BlockBookmarkResource? {
        didSet {
            self.handle(self.resource)
        }
    }
    
    /// Views
    private var contentView: UIView!
    private var titleView: UILabel!
    private var descriptionView: UILabel!
    private var iconView: UIImageView!
    private var urlView: UILabel!
    
    private var leftStackView: UIStackView!
    private var urlStackView: UIStackView!
    
    private var imageView: UIImageView!
    
    private var imageViewWidthConstraint: NSLayoutConstraint?
    private var imageViewHeightConstraint: NSLayoutConstraint?
    
    /// Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    /// Setup
    func setup() {
        self.setupUIElements()
        self.addLayout()
    }

    /// UI Elements
    func setupUIElements() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
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
            view.font = self.style.titleFont
            view.textColor = self.style.titleColor
            return view
        }()
        
        self.descriptionView = {
            let view = UILabel()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.numberOfLines = 3
            view.lineBreakMode = .byWordWrapping
            view.font = self.style.subtitleFont
            view.textColor = self.style.subtitleColor
            return view
        }()
        
        self.iconView = {
            let view = UIImageView()
            view.contentMode = .scaleAspectFit
            view.clipsToBounds = true
            view.heightAnchor.constraint(equalToConstant: Constants.Layout.iconHeight).isActive = true
            view.widthAnchor.constraint(equalToConstant: Constants.Layout.iconHeight).isActive = true
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()

        self.urlView = {
            let view = UILabel()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.font = self.style.urlFont
            view.textColor = self.style.urlColor
            return view
        }()
        
        self.imageView = {
            let view = UIImageView()
            view.contentMode = .scaleAspectFit
            view.clipsToBounds = true
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        self.urlStackView.addArrangedSubview(self.iconView)
        self.urlStackView.addArrangedSubview(self.urlView)
        
        self.leftStackView.addArrangedSubview(self.titleView)
        self.leftStackView.addArrangedSubview(self.descriptionView)
        self.leftStackView.addArrangedSubview(self.urlStackView)
        
        self.contentView.addSubview(self.leftStackView)
        self.contentView.addSubview(self.imageView)
        
        self.addSubview(self.contentView)
        
        self.leftStackView.backgroundColor = .systemGray6
        self.imageView.backgroundColor = .systemGray2
    }
    
    /// Layout
    func addLayout() {
        if let view = self.contentView, let superview = view.superview {
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                view.topAnchor.constraint(equalTo: superview.topAnchor),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ])
        }
        
        if let view = self.leftStackView, let superview = view.superview {
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: Constants.Layout.commonInsets.left),
                view.trailingAnchor.constraint(lessThanOrEqualTo: superview.trailingAnchor, constant: -Constants.Layout.commonInsets.right),
                view.topAnchor.constraint(equalTo: superview.topAnchor, constant: Constants.Layout.commonInsets.top),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -Constants.Layout.commonInsets.bottom)
            ])
        }
    }
    
    func addLayoutForImageView() {
        if let view = self.imageView, let superview = view.superview, let leftView = self.leftStackView {
            self.imageViewWidthConstraint = view.widthAnchor.constraint(equalTo: superview.widthAnchor, multiplier: Constants.Layout.imageSizeFactor)
            self.imageViewWidthConstraint?.isActive = true
            
            self.imageViewHeightConstraint = view.heightAnchor.constraint(equalToConstant: Constants.Layout.imageHeightConstant)
            self.imageViewHeightConstraint?.isActive = true
//                self.imageViewHeightConstraint?.priority = .defaultLow
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: leftView.trailingAnchor, constant: Constants.Layout.commonInsets.left),
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
    func handle(_ value: BlockBookmarkResource?) {
        guard let value = value else {
            print("value is nil!")
            return
        }
        switch value.state {
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
    
    func configured(_ stream: AnyPublisher<BlockBookmarkResource?, Never>) {
        self.resourceStream = stream
        self.subscription = self.resourceStream.receiveOnMain().sink(receiveValue: { [weak self] (value) in
            print("state value: \(String(describing: value))")
            self?.resource = value
        })
    }
}

// MARK: - UIView / WithBookmark / Style
private extension BlockBookmarkView {
    enum Style {
        case presentation
        
        var titleFont: UIFont {
            switch self {
            case .presentation: return .systemFont(ofSize: 15, weight: .semibold)
            }
        }
        var subtitleFont: UIFont {
            switch self {
            case .presentation: return .systemFont(ofSize: 15)
            }
        }
        var urlFont: UIFont {
            switch self {
            case .presentation: return .systemFont(ofSize: 15, weight: .light)
            }
        }
                
        var titleColor: UIColor {
            switch self {
            case .presentation: return .grayscale90
            }
        }
        var subtitleColor: UIColor {
            switch self {
            case .presentation: return .gray
            }
        }
        var urlColor: UIColor {
            switch self {
            case .presentation: return .grayscale90
            }
        }
    }
}

// MARK: - UIView / WithBookmark / Layout
private extension BlockBookmarkView {
    
    enum Constants {
        enum Layout {
            static let commonInsets: UIEdgeInsets = .init(top: 16, left: 16, bottom: 16, right: 16)
            static let spacing: CGFloat = 5
            static let imageSizeFactor: CGFloat = 1 / 3
            static let imageHeightConstant: CGFloat = 150
            static let iconHeight: CGFloat = 24
        }
    }
}

