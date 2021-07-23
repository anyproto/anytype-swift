import Combine
import BlocksModels
import UIKit

class BlocksFileEmptyView: UIView & UIContentView {
    private var currentConfiguration: BlocksFileEmptyViewConfiguration
        var configuration: UIContentConfiguration {
            get { currentConfiguration }
            set {
                guard let newConfiguration = newValue as? BlocksFileEmptyViewConfiguration else {
                    assertionFailure("Wrong configuration: \(newValue) for block file empty view")
                    return
                }
                self.currentConfiguration = newConfiguration
                apply(configuration: newConfiguration)
            }
        }
    
    init(configuration: BlocksFileEmptyViewConfiguration) {
        self.currentConfiguration = configuration
        super.init(frame: .zero)
        
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSubview(backgroundVew) {
            $0.pinToSuperview()
        }
        
        backgroundVew.addSubview(contentView) {
            $0.height.equal(to: 48)
            $0.pinToSuperview(insets: Layout.placeholderInsets)
        }
        
        contentView.layoutUsing.stack {
            $0.hStack(
                $0.hGap(fixed: Layout.iconLeading),
                icon,
                $0.hGap(fixed: Layout.labelSpacing),
                label,
                $0.hGap(fixed: Layout.labelSpacing),
                activityIndicator,
                $0.hGap(fixed: Layout.activityIndicatorTrailing)
            )
        }
    
        icon.layoutUsing.anchors {
            $0.width.equal(to: Layout.iconSize.width)
            $0.height.equal(to: Layout.iconSize.height)
        }
    }
    
    // MARK: - New configuration
    func apply(configuration: BlocksFileEmptyViewConfiguration) {
        label.text = configuration.text
        icon.image = configuration.image
        
        change(state: .empty)
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
            self.label.text = currentConfiguration.text
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
        case .uploading:
            self.label.text = Constants.uploadingText
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        case .error:
            self.label.text = Constants.errorText
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
        }
    }
    
    private let backgroundVew = UIView()
    
    private let contentView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.grayscale30.cgColor
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        return view
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = .body
        label.textColor = .grayscale50
        return label
    }()
    
    private let icon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
             
    private let activityIndicator: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView()
        loader.color = .grayscale50
        loader.hidesWhenStopped = true
        return loader
    }()
}


extension BlocksFileEmptyView {
    private enum Layout {
        static let placeholderInsets = UIEdgeInsets(top: 7, left: 20, bottom: -7, right: -20)
        static let iconLeading: CGFloat = 12
        static let labelSpacing: CGFloat = 10
        static let activityIndicatorTrailing: CGFloat = 18
        static let iconSize = CGSize(width: 20, height: 20)
    }
    
    private enum Constants {
        static let errorText = "Error, try again later"
        static let uploadingText = "Uploading..."
    }
}
