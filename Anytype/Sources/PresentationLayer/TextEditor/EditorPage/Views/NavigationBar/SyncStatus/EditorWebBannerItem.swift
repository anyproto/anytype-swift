import UIKit
import Services
import Loc

final class EditorWebBannerItem: UIView {
    private lazy var label: UILabel = {
        let label = UILabel()

        let attributedString = NSMutableAttributedString()

        let liveOnWebAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.caption1Regular,
            .foregroundColor: UIColor.Text.primary
        ]
        attributedString.append(NSAttributedString(string: Loc.Publishing.WebBanner.liveOnWeb + " ", attributes: liveOnWebAttributes))

        let viewSiteAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.caption1Semibold,
            .foregroundColor: UIColor.Text.primary
        ]
        attributedString.append(NSAttributedString(string: Loc.Publishing.WebBanner.viewSite, attributes: viewSiteAttributes))

        label.attributedText = attributedString
        label.textAlignment = .center
        return label
    }()

    private let glassBackground = GlassEffectViewIOS26()
    private var heightConstraint: NSLayoutConstraint?

    private let onTap: () -> ()

    func setVisible(_ visible: Bool) {
        isHidden = !visible
        heightConstraint?.constant = visible ? 40 : 0
    }

    init(onTap: @escaping () -> ()) {
        self.onTap = onTap
        super.init(frame: .zero)
        setup()
    }

    // MARK: - Private

    private func setup() {
        heightConstraint = heightAnchor.constraint(equalToConstant: 40)
        heightConstraint?.isActive = true

        glassBackground.applyCapsuleShape(height: 40)

        addSubview(glassBackground) { $0.pinToSuperview() }
        glassBackground.glassContentView.addSubview(label) {
            $0.pinToSuperview(insets: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)

        setVisible(false)
    }

    @objc private func handleTap() {
        UISelectionFeedbackGenerator().selectionChanged()
        onTap()
    }

    // MARK: - Unavailable
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
