import SwiftUI

final class TemplateAvailabilityPopupView: UIView {

    private lazy var titleLabel = UILabel()
    private lazy var descriptionLabel = UILabel()

    private lazy var button = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureViews()
        setupLayout()
    }

    func update(
        with templatesCount: Int,
        onShowAction: @escaping () -> Void
    ) {
        titleLabel.text = "Alert.Templates_Available.Title.First".localized + " \(templatesCount) " + "Alert.Templates_Available.Title.Second".localized

        let action = UIAction { _ in
            onShowAction()
        }

        button.addAction(action, for: .touchUpInside)
    }

    private func configureViews() {
        titleLabel.font = .bodyRegular
        titleLabel.textColor = .textPrimary

        descriptionLabel.text = "Alert.Templates_Available.Description".localized
        descriptionLabel.font = .relation3Regular
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
    }

    private func setupLayout() {
        layoutUsing.stack {
            $0.edgesToSuperview(insets: Constants.edgeInsets)
        } builder: {
            $0.hStack(
                $0.vStack(
                    titleLabel,
                    $0.vGap(fixed: 1),
                    descriptionLabel
                ),
                button
            )
        }
    }
}

private extension TemplateAvailabilityPopupView {
    enum Constants {
        static let edgeInsets = UIEdgeInsets(top: 14, left: 20, bottom: 24, right: 20)
    }
}
