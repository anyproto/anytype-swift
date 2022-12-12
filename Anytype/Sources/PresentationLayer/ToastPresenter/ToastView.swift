import UIKit

final class ToastView: UIView {
    private lazy var label = TappableLabel(frame: .zero)

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

    private func setupView() {
        label.textColor = .textPrimary
        label.textAlignment = .center;
        label.font = AnytypeFont.caption1Medium.uiKitFont
        label.numberOfLines = 0

        backgroundColor = .clear
        
        let wrapperView = UIView()
        addSubview(wrapperView) {
            $0.pinToSuperview(excluding: [.left, .right])
            $0.leading.greaterThanOrEqual(to: leadingAnchor)
            $0.trailing.lessThanOrEqual(to: trailingAnchor)
            $0.centerX.equal(to: centerXAnchor)
        }
        
        wrapperView.backgroundColor = .backgroundBlack
        wrapperView.layer.cornerRadius = 8
        wrapperView.layer.masksToBounds = true
        wrapperView.layer.borderWidth = 1
        wrapperView.layer.borderColor = UIColor.strokePrimary.withAlphaComponent(0.14).cgColor
        
        wrapperView.addSubview(label) {
            $0.pinToSuperview(
                insets: .init(top: 12, left: 24, bottom: 12, right: 24)
            )
        }
    }
}
