import UIKit

final class ActivityIndicatorView: UIView {
    
    // MARK: - Private variables
    
    private let imageView = UIImageView()
    
    private let activityIndicatorView = UIActivityIndicatorView()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupView()
    }
    
}

// MARK: - Internal extension

extension ActivityIndicatorView {
    
    func show(with image: UIImage? = nil) {
        imageView.image = image
        activityIndicatorView.startAnimating()
        
        isHidden = false
    }
    
    func hide() {
        activityIndicatorView.stopAnimating()
        
        isHidden = true
    }
    
}

// MARK: - Private extension

private extension ActivityIndicatorView {
    
    func setupView() {
        setupImageView()
        setupActivityIndicatorView()
        
        setupLayout()
    }
    
    func setupImageView() {
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
    }
    
    func setupActivityIndicatorView() {
        activityIndicatorView.color = .grayscale10
        activityIndicatorView.backgroundColor = UIColor(white: 0.0, alpha: 0.32)
    }
    
    func setupLayout() {
        addSubview(imageView) {
            $0.pinToSuperview()
        }
        
        addSubview(activityIndicatorView) {
            $0.pinToSuperview()
        }
    }
    
}
