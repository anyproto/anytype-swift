import Combine
import BlocksModels
import UIKit

extension BlocksViewsBaseFileTopUIKitEmptyView {
    private enum Layout {
        static let placeholderViewInsets = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        static let placeholderIconLeading: CGFloat = 12
        static let placeholderLabelSpacing: CGFloat = 4
        static let activityIndicatorTrailing: CGFloat = 18
    }
    
    private enum Constants {
        static let errorText = "Error, try again later"
        static let uploadingText = "Uploading..."
    }
    
    struct ViewData {
        let image: UIImage?
        let placeholderText: String
    }
}


class BlocksViewsBaseFileTopUIKitEmptyView: UIView {
//    self.placeholderIcon.image = resource.image
    
    // MARK: - Publishers
    private var subscription: AnyCancellable?
    @Published private var hasError: Bool = false
    
    // MARK: Views
    private var contentView: UIView!
    
    private var placeholderView: UIView!
    private var placeholderLabel: UILabel!
    private var placeholderIcon: UIImageView!
    
    private var activityIndicator: UIActivityIndicatorView!
    
    private let viewData: ViewData
    
    // MARK: Initialization
    init(viewData: ViewData) {
        self.viewData = viewData
        super.init(frame: .zero)
        self.setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup
    private func setup() {
        self.setupUIElements()
        self.addLayout()
    }
    
    // MARK: UI Elements
    private func setupUIElements() {
        self.setupEmptyView()
    }
    
    private func setupEmptyView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        // TODO: Move colors to service or smt
        self.placeholderView = {
            let view = UIView()
            view.layer.borderWidth = 1
            view.layer.borderColor = UIColor(hexString: "#DFDDD0").cgColor
            view.layer.cornerRadius = 4
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        self.placeholderLabel = {
            let label = UILabel()
            label.text = viewData.placeholderText
            label.textColor = UIColor(hexString: "#ACA996")
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        self.activityIndicator = {
            let loader = UIActivityIndicatorView()
            loader.color = UIColor(hexString: "#ACA996")
            loader.hidesWhenStopped = true
            loader.translatesAutoresizingMaskIntoConstraints = false
            return loader
        }()
        
        self.placeholderIcon = {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.image = viewData.image
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()
        
        self.placeholderView.addSubview(placeholderLabel)
        self.placeholderView.addSubview(placeholderIcon)
        self.addSubview(placeholderView)
        self.addSubview(activityIndicator)
    }
            
    // MARK: Layout
    private func addLayout() {
        
        if let view = self.placeholderView, let superview = view.superview {
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: Layout.placeholderViewInsets.left),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -Layout.placeholderViewInsets.right),
                view.topAnchor.constraint(equalTo: superview.topAnchor, constant: Layout.placeholderViewInsets.top),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -Layout.placeholderViewInsets.bottom)
                
            ])
        }
        
        if let view = self.placeholderIcon, let superview = view.superview {
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: Layout.placeholderIconLeading),
                view.centerYAnchor.constraint(equalTo: superview.centerYAnchor),
                view.widthAnchor.constraint(equalToConstant: view.intrinsicContentSize.width)
            ])
        }
        
        if let view = self.placeholderLabel, let superview = view.superview {
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: self.placeholderIcon.trailingAnchor, constant: Layout.placeholderLabelSpacing),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                view.topAnchor.constraint(equalTo: superview.topAnchor),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ])
        }
        
        if let view = self.activityIndicator, let superview = view.superview {
            NSLayoutConstraint.activate([
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -Layout.activityIndicatorTrailing),
                view.centerYAnchor.constraint(equalTo: superview.centerYAnchor),
                view.widthAnchor.constraint(equalToConstant: view.intrinsicContentSize.width)
            ])
        }
        
    }
    
    // MARK: - Actions
    enum State {
        case empty
        case uploading
        case error
    }
    
    func change(state: State) {
        switch state {
        case .empty:
            self.placeholderLabel.text = viewData.placeholderText
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
        case .uploading:
            self.placeholderLabel.text = Constants.uploadingText
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        case .error:
            self.placeholderLabel.text = Constants.errorText
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
        }
    }
    
    // MARK: - Configurations
    
    func configured(_ stream: Published<Bool>) {
        self._hasError = stream
        self.subscription = self.$hasError.sink(receiveValue: { [weak self] (value) in
            if value {
                self?.change(state: .error)
            }
            else {
                self?.change(state: .uploading)
            }
        })
    }
}
