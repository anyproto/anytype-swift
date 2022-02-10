import UIKit

final class RoundedShadowView<View: UIView>: UIView {
    let view: View
    let shadowLayer: CAShapeLayer
    private let cornerRadius: CGFloat

    init(view: View, cornerRadius: CGFloat) {
        self.view = view
        self.cornerRadius = cornerRadius
        view.layer.cornerRadius = cornerRadius
        view.layer.masksToBounds = true

        self.shadowLayer = CAShapeLayer()

        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowOpacity = 1

        super.init(frame: view.bounds)

        setupLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        shadowLayer.frame = view.bounds

        shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }

    private func setupLayout() {
        layer.insertSublayer(shadowLayer, at: 0)

        addSubview(view) {
            $0.pinToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
