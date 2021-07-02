import Combine
import BlocksModels
import UIKit

extension BlocksFileEmptyView {
    private enum Layout {
        static let placeholderInsets = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        static let iconLeading: CGFloat = 12
        static let labelSpacing: CGFloat = 4
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


class BlocksFileEmptyView: UIView {
    private let viewData: ViewData
    
    init(viewData: ViewData) {
        self.viewData = viewData
        super.init(frame: .zero)
        
        setupEmptyView()
        addLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupEmptyView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        placeholderLabel.text = viewData.placeholderText
        placeholderIcon.image = viewData.image
        
        
        placeholderView.addSubview(placeholderLabel)
        placeholderView.addSubview(placeholderIcon)
        
        self.addSubview(placeholderView)
        self.addSubview(activityIndicator)
    }
            
    // MARK: Layout
    private func addLayout() {
        NSLayoutConstraint.activate([
            placeholderView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Layout.placeholderInsets.left),
            placeholderView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Layout.placeholderInsets.right),
            placeholderView.topAnchor.constraint(equalTo: self.topAnchor, constant: Layout.placeholderInsets.top),
            placeholderView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -Layout.placeholderInsets.bottom)
            
        ])
        
        NSLayoutConstraint.activate([
            placeholderIcon.leadingAnchor.constraint(equalTo: placeholderView.leadingAnchor, constant: Layout.iconLeading),
            placeholderIcon.centerYAnchor.constraint(equalTo: placeholderView.centerYAnchor),
            placeholderIcon.widthAnchor.constraint(equalToConstant: placeholderIcon.intrinsicContentSize.width)
        ])
        
        NSLayoutConstraint.activate([
            placeholderLabel.leadingAnchor.constraint(equalTo: placeholderIcon.trailingAnchor, constant: Layout.labelSpacing),
            placeholderLabel.trailingAnchor.constraint(equalTo: placeholderView.trailingAnchor),
            placeholderLabel.topAnchor.constraint(equalTo: placeholderView.topAnchor),
            placeholderLabel.bottomAnchor.constraint(equalTo: placeholderView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            activityIndicator.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Layout.activityIndicatorTrailing),
            activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            activityIndicator.widthAnchor.constraint(equalToConstant: activityIndicator.intrinsicContentSize.width)
        ])
        
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
    
    // MARK: - Views
    private let placeholderView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.grayscale30.cgColor
        view.layer.cornerRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.grayscale50
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let placeholderIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
             
    private let activityIndicator: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView()
        loader.color = UIColor.grayscale50
        loader.hidesWhenStopped = true
        loader.translatesAutoresizingMaskIntoConstraints = false
        return loader
    }()
}
