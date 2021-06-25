import UIKit
import Combine

class BlocksViewsFileUIKitViewWithFile: UIView {
    struct Resource {
        var size: String
        var name: String
        var typeIcon: UIImage?
    }
    
    /// Publishers
    var subscription: AnyCancellable?
    @Published var resource: Resource? {
        didSet {
            self.handle(self.resource)
        }
    }
    
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
        
        self.imageView = {
            let view = UIImageView()
            view.contentMode = .center
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        self.titleView = {
            let view = UILabel()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.font = .systemFont(ofSize: 15)
            view.textColor = .grayscale90
            return view
        }()
        
        self.sizeView = {
            let view = UILabel()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.font = .systemFont(ofSize: 13)
            view.textColor = .lightGray
            return view
        }()
        
        self.addSubview(self.imageView)
        self.addSubview(self.titleView)
        self.addSubview(self.sizeView)
    }
    
    /// Layout
    func addLayout() {
        let offset: CGFloat = 10
        
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
        self.imageView.image = value?.typeIcon
        self.sizeView.text = value?.size
    }
    
    func configured(_ stream: AnyPublisher<Resource?, Never>) {
        self.subscription = stream.receiveOnMain().sink(receiveValue: { [weak self] (value) in
            self?.resource = value
        })
    }
}
