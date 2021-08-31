import UIKit

final class ActivityIndicatorView: UIView {
    
    // `UIActivityIndicatorView` stop animating because we update collection view in `UIView.performWithoutAnimation` block. So we show only dimmed background for now
//    private let activityIndicatorView = UIActivityIndicatorView()
    private let activityIndicatorView = UIView()
    
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
    
    func show() {
//        activityIndicatorView.startAnimating()
        isHidden = false
    }
    
    func hide() {
//        activityIndicatorView.stopAnimating()
        isHidden = true
    }
    
}

// MARK: - Private extension

private extension ActivityIndicatorView {
    
    func setupView() {
        setupActivityIndicatorView()
        
        setupLayout()
    }
    
    func setupActivityIndicatorView() {
//        activityIndicatorView.color = .grayscale10
        activityIndicatorView.backgroundColor = UIColor(white: 0.0, alpha: 0.32)
    }
    
    func setupLayout() {
        addSubview(activityIndicatorView) {
            $0.pinToSuperview()
        }
    }
    
}
