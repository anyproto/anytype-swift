import UIKit
import Combine
import Assets
import LayoutKit

final class ToastView: UIView {
    private lazy var label = TappableLabel(frame: .zero)
    private var bottomConstraint: NSLayoutConstraint?
    
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

    private func setupView() {
        label.textColor = .Text.primary
        label.textAlignment = .center
        label.font = AnytypeFont.caption1Regular.uiKitFont
        label.numberOfLines = 3

        backgroundColor = .clear
        
        let wrapperView = UIView()
        addSubview(wrapperView) {
            $0.pinToSuperview(excluding: [.left, .right, .bottom])
            $0.leading.greaterThanOrEqual(to: leadingAnchor)
            $0.trailing.lessThanOrEqual(to: trailingAnchor)
            $0.centerX.equal(to: centerXAnchor)
            bottomConstraint = $0.bottom.equal(to: bottomAnchor)
        }
        
        wrapperView.backgroundColor = .BackgroundCustom.black
        wrapperView.layer.cornerRadius = 8
        wrapperView.layer.masksToBounds = true
        wrapperView.layer.borderWidth = 1
        wrapperView.layer.borderColor = UIColor.Shape.primary.withAlphaComponent(0.14).cgColor
        
        wrapperView.addSubview(label) {
            $0.pinToSuperview(
                insets: .init(top: 12, left: 16, bottom: 12, right: 16)
            )
        }
    }
}
