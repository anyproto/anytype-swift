import UIKit
import Combine

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
        label.textColor = .TextNew.primary
        label.textAlignment = .center;
        label.font = AnytypeFont.caption1Medium.uiKitFont
        label.numberOfLines = 0

        backgroundColor = .clear
        
        let wrapperView = UIView()
        addSubview(wrapperView) {
            $0.pinToSuperview(excluding: [.left, .right, .bottom])
            $0.leading.greaterThanOrEqual(to: leadingAnchor)
            $0.trailing.lessThanOrEqual(to: trailingAnchor)
            $0.centerX.equal(to: centerXAnchor)
            bottomConstraint = $0.bottom.equal(to: bottomAnchor)
        }
        
        wrapperView.backgroundColor = .BackgroundNew.backgroundBlack
        wrapperView.layer.cornerRadius = 8
        wrapperView.layer.masksToBounds = true
        wrapperView.layer.borderWidth = 1
        wrapperView.layer.borderColor = UIColor.Stroke.primary.withAlphaComponent(0.14).cgColor
        
        wrapperView.addSubview(label) {
            $0.pinToSuperview(
                insets: .init(top: 12, left: 24, bottom: 12, right: 24)
            )
        }
    }
}
