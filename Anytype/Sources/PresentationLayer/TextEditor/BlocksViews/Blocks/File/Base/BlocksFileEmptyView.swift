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
        
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        layer.borderWidth = 1
        layer.borderColor = UIColor.grayscale30.cgColor
        layer.cornerRadius = 4
        clipsToBounds = true
        self.layoutMargins = Layout.placeholderInsets
        
        placeholderLabel.text = viewData.placeholderText
        placeholderIcon.image = viewData.image
        
        addSubview(placeholderIcon) {
            $0.centerY.equal(to: centerYAnchor)
            $0.leading.equal(to: leadingAnchor, constant: Layout.iconLeading)
            $0.width.equal(to: 20)
            $0.height.equal(to: 20)
        }
        addSubview(placeholderLabel) {
            $0.pinToSuperview(excluding: [.left])
            $0.leading.equal(to: placeholderIcon.trailingAnchor, constant: Layout.labelSpacing)
        }
        addSubview(activityIndicator) {
            $0.trailing.equal(to: trailingAnchor, constant: -Layout.activityIndicatorTrailing)
            $0.centerY.equal(to: centerYAnchor)
            $0.width.equal(to: activityIndicator.intrinsicContentSize.width)
            $0.height.equal(to: activityIndicator.intrinsicContentSize.height)
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
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = .body
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
