import UIKit

final class TemplateAvailabilityPopupView: UIView {

    private lazy var titleLabel = UILabel()
    private lazy var button = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setup() {
        let hstack = UIStackView()
        hstack.axis = .horizontal
        hstack.alignment = .center

        let vstack = UIStackView()
        vstack.axis = .vertical
        vstack.spacing = 1

        titleLabel.font = .bodyRegular
        titleLabel.textColor = .textPrimary

        let descriptionLabel = UILabel()
        descriptionLabel.text = "Alert.Templates_Available.Description".localized
        descriptionLabel.font = .bodyRegular.withSize(12)
        descriptionLabel.textColor = .textSecondary

        button.setTitle("Alert.Templates_Available.Button".localized, for: .normal)
        button.setTitleColor(.textPrimary, for: .normal)
        button.titleLabel?.font = .calloutRegular
        button.widthAnchor.constraint(equalToConstant: 80).isActive = true
        button.heightAnchor.constraint(equalToConstant: 36).isActive = true
        button.layer.borderColor = UIColor.strokePrimary.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true

        vstack.addArrangedSubview(titleLabel)
        vstack.addArrangedSubview(descriptionLabel)

        hstack.addArrangedSubview(vstack)
        hstack.addArrangedSubview(button)

        addSubview(hstack) {
            $0.pinToSuperview(insets: .init(top: 0, left: 20, bottom: 0, right: -20))
        }

        translatesAutoresizingMaskIntoConstraints = false
        let heightConstraint = heightAnchor.constraint(equalToConstant: 84)
        heightConstraint.priority = .init(rawValue: 999)
        heightConstraint.isActive = true
    }

    func update(
        with templatesCount: Int,
        onShowAction: () -> Void
    ) {
        titleLabel.text = "Alert.Templates_Available.Title.First".localized + " \(templatesCount) " + "Alert.Templates_Available.Title.Second".localized
    }
}
