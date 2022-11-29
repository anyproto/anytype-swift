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

        backgroundColor = .backgroundSecondary
        layer.cornerRadius = 8
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.strokePrimary.withAlphaComponent(0.14).cgColor

        addSubview(label) {
            $0.pinToSuperview(
                insets: .init(top: 12, left: 24, bottom: -12, right: -24)
            )
        }
    }
}
