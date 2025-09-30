import UIKit
import Combine
import Assets
import LayoutKit

final class ToastView: UIView {
    private lazy var label = TappableLabel(frame: .zero)
    private var bottomConstraint: NSLayoutConstraint?
    private var wrapperView: UIView?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupView()
    }

    func setMessage(_ message: NSAttributedString) {
        label.attributedText = message
    }

    func updateBottomInset(_ inset: CGFloat) {
        bottomConstraint?.constant = -inset
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        wrapperView?.layer.cornerRadius = (wrapperView?.bounds.height ?? 0) / 2
    }

    private func setupView() {
        label.textColor = .Text.primary
        label.textAlignment = .center
        label.font = AnytypeFont.caption1Medium.uiKitFont
        label.numberOfLines = 3

        backgroundColor = .clear

        let wrapper = UIView()
        self.wrapperView = wrapper
        addSubview(wrapper) {
            $0.pinToSuperview(excluding: [.left, .right, .bottom])
            $0.leading.greaterThanOrEqual(to: leadingAnchor)
            $0.trailing.lessThanOrEqual(to: trailingAnchor)
            $0.centerX.equal(to: centerXAnchor)
            bottomConstraint = $0.bottom.equal(to: bottomAnchor)
        }

        wrapper.backgroundColor = .BackgroundCustom.black
        wrapper.layer.cornerCurve = .continuous
        wrapper.layer.masksToBounds = true
        wrapper.layer.borderWidth = 1
        wrapper.layer.borderColor = UIColor.Shape.primary.withAlphaComponent(0.14).cgColor

        wrapper.addSubview(label) {
            $0.pinToSuperview(
                insets: .init(top: 13, left: 16, bottom: 13, right: 16)
            )
        }
    }
}
