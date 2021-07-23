
import UIKit
import Kingfisher

final class DocumentCoverView: UIView {
    
    // MARK: - Views
    
    private let activityIndicatorView = ActivityIndicatorView()

    private let imageView = UIImageView()
    
    // MARK: - Variables
    
    private var heightConstraint: NSLayoutConstraint!
    
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

extension DocumentCoverView: ConfigurableView {
    
    func configure(model: DocumentCoverViewState) {
        switch model {
        case let .cover(cover):
            configureCoverState(cover)
        case let .preview(image):
            configurePreviewState(image)
        case .empty:
            configureEmptyState()
        }
    }
    
    private func configureCoverState(_ cover: DocumentCover) {
        activityIndicatorView.hide()

        heightConstraint.constant = Constants.height
        imageView.isHidden = false
        
        switch cover {
        case let .imageId(imageId):
            showImageWithId(imageId)
        case let .color(color):
            showImageBasedOnColor(color)
        case let .gradient(startColor, endColor):
            showImageBaseOnGradient(startColor, endColor)
        }
    }
    
    private func showImageWithId(_ imageId: String) {
        let placeholder = PlaceholderImageBuilder.placeholder(
            with: ImageGuideline(
                size: CGSize(width: 1, height: Constants.height)
            ),
            color: UIColor.grayscale10
        )
        
        imageView.kf.setImage(
            with: UrlResolver.resolvedUrl(.image(id: imageId, width: .default)),
            placeholder: placeholder
        )
        imageView.contentMode = .scaleAspectFill
    }
    
    private func showImageBasedOnColor(_ color: UIColor) {
        imageView.image = PlaceholderImageBuilder.placeholder(
            with: ImageGuideline(
                size: CGSize(width: 1, height: Constants.height)
            ),
            color: color
        )
        imageView.contentMode = .scaleAspectFill
    }
    
    private func showImageBaseOnGradient(_ startColor: UIColor, _ endColor: UIColor) {
        imageView.image = PlaceholderImageBuilder.gradient(
            size: CGSize(width: 1, height: Constants.height),
            startColor: startColor,
            endColor: endColor,
            startPoint: CGPoint(x: 0.5, y: 0),
            endPoint: CGPoint(x: 0.5, y: 1)
        )
        imageView.contentMode = .scaleToFill
    }
    
    private func configurePreviewState(_ image: UIImage?) {
        heightConstraint.constant = Constants.height
        imageView.isHidden = false
        
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        
        let animation = CATransition()
        animation.type = .fade;
        animation.duration = 0.3;
        activityIndicatorView.layer.add(animation, forKey: nil)
        
        activityIndicatorView.show()
    }
    
    private func configureEmptyState() {
        activityIndicatorView.hide()
        
        heightConstraint.constant = 0
        
        imageView.isHidden = true
        imageView.image = nil
    }
    
}

// MARK: - Private extension

private extension DocumentCoverView {
    
    func setupView() {
        imageView.clipsToBounds = true
        
        setupLayout()
    }
    
    func setupLayout() {
        layoutUsing.anchors {
            self.heightConstraint = $0.height.equal(to: 0)
        }
        
        addSubview(imageView) {
            $0.pinToSuperview()
        }
        
        addSubview(activityIndicatorView) {
            $0.pinToSuperview()
        }
    }
    
}

private extension DocumentCoverView {
    
    enum Constants {
        static let height: CGFloat = 224
    }
    
}
