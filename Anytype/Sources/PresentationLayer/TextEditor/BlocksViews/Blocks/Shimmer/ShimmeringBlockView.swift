import UIKit
import ShimmerSwift

final class ShimmeringBlockView: UIView, BlockContentView {
    private let shimmeringView = ShimmeringView()
    private let imageView = UIImageView()
    private var heightConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = .clear

        imageView.tintColor = .Shape.tertiary
        shimmeringView.contentView = imageView
        
        addSubview(shimmeringView) {
            $0.pinToSuperview(excluding: [.bottom])
            $0.bottom.greaterThanOrEqual(to: bottomAnchor)
            heightConstraint = $0.height.equal(to: 20) // will be updated with configuration
        }
    }

    func update(with configuration: ShimmeringBlockConfiguration) {
        imageView.image = UIImage(asset: configuration.image)
        heightConstraint?.constant = imageView.image?.size.height ?? 20

        shimmeringView.isShimmering = true
        shimmeringView.shimmerSpeed = 120
    }
}

