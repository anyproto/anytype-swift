import UIKit
import Combine

class BlocksViewsFileUIKitViewWithFile: UIView {
    enum Style {
        case presentation
        var titleFont: UIFont {
            switch self {
            case .presentation: return .systemFont(ofSize: 15)
            }
        }
        var sizeFont: UIFont {
            switch self {
            case .presentation: return .systemFont(ofSize: 13)
            }
        }
        var titleColor: UIColor {
            switch self {
            case .presentation: return .grayscale90
            }
        }
        var sizeColor: UIColor {
            switch self {
            case .presentation: return .lightGray
            }
        }
    }
    
    struct Layout {
        var offset: CGFloat = 10
    }
    
    struct Resource {
        var size: String
        var name: String
        var mime: String
    }
    
    /// Variables
    var style: Style = .presentation {
        didSet {
            self.titleView.font = self.style.titleFont
            self.sizeView.font = self.style.sizeFont
        }
    }
    
    var layout: Layout = .init()
    
    /// Publishers
    var subscription: AnyCancellable?
    @Published var resource: Resource? {
        didSet {
            self.handle(self.resource)
        }
    }
    
    /// Views
    var contentView: UIView!
    var imageView: UIImageView!
    var titleView: UILabel!
    var sizeView: UILabel!
    
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
        
        self.imageView = {
            let view = UIImageView()
            view.contentMode = .center
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
        
        self.sizeView = {
            let view = UILabel()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.font = self.style.sizeFont
            view.textColor = self.style.sizeColor
            return view
        }()
        
        self.contentView.addSubview(self.imageView)
        self.contentView.addSubview(self.titleView)
        self.contentView.addSubview(self.sizeView)
        
        self.addSubview(self.contentView)
    }
    
    /// Layout
    func addLayout() {
        let offset: CGFloat = self.layout.offset
        
        if let view = self.contentView, let superview = view.superview {
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                view.topAnchor.constraint(equalTo: superview.topAnchor),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ])
        }
        
        if let view = self.imageView, let superview = view.superview {
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: offset),
                view.topAnchor.constraint(equalTo: superview.topAnchor),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ])
        }
        
        if let view = self.titleView, let superview = view.superview, let leftView = self.imageView {
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: leftView.trailingAnchor, constant: offset),
                view.topAnchor.constraint(equalTo: superview.topAnchor),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ])
        }

        if let view = self.sizeView, let superview = view.superview, let leftView = self.titleView {
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: leftView.trailingAnchor, constant: offset),
                view.trailingAnchor.constraint(lessThanOrEqualTo: superview.trailingAnchor, constant: -offset),
                view.topAnchor.constraint(equalTo: superview.topAnchor),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ])
        }
    }
    
    /// Configurations
    func handle(_ value: Resource?) {
        self.titleView.text = value?.name
        self.imageView.image = UIImage.init(named: value?.mime ?? "")
        self.sizeView.text = value?.size
    }
    
    func configured(_ stream: AnyPublisher<Resource?, Never>) {
        self.subscription = stream.receiveOnMain().sink(receiveValue: { [weak self] (value) in
            self?.resource = value
        })
    }
}
