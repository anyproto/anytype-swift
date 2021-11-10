import UIKit

final class RoundedShadowView<View: UIView>: UIView {
    let view: View
    let shadowLayer: CAShapeLayer
    private let cornerRadius: CGFloat

    init(view: View, cornerRadius: CGFloat) {
        self.view = view
        self.cornerRadius = cornerRadius

        self.shadowLayer = CAShapeLayer()

        shadowLayer.shadowPath = shadowLayer.path

        super.init(frame: view.frame)

        setupLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        shadowLayer.frame = view.frame

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
