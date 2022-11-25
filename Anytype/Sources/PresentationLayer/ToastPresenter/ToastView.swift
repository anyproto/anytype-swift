import UIKit

// Non-final toast view. Should be designed by design team
final class ToastView: ThroughHitView {
    private lazy var label = UILabel(frame: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupView()
    }

    func setMessage(_ message: String) {
        label.text = message
    }

    private func setupView() {
        backgroundColor = .clear

        label.textColor = .textWhite
        label.textAlignment = .center;
        label.font = AnytypeFont.caption1Medium.uiKitFont
        label.numberOfLines = 0

        let decoratedView = UIView()
        decoratedView.backgroundColor = .buttonActive
        decoratedView.layer.cornerRadius = 8
        decoratedView.layer.masksToBounds = true

        addSubview(decoratedView) {
            $0.centerX.equal(to: centerXAnchor)
        }

        NSLayoutConstraint(
            item: decoratedView,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: self,
            attribute: .centerY,
            multiplier: 1.5,
            constant: 0
        ).isActive = true


        decoratedView.addSubview(label) {
            $0.pinToSuperview(insets: .init(top: 8, left: 8, bottom: 8, right: 8))
        }
    }
}

class ThroughHitView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return nil
    }
}
