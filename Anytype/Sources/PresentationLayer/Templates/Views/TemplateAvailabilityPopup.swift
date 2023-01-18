import UIKit

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
        titleLabel.text = Loc.Alert.TemplatesAvailable.title(templatesCount)

        let action = UIAction { _ in
            onShowAction()
        }

        button.addAction(action, for: .touchUpInside)
    }

    private func configureViews() {
        titleLabel.font = .bodyRegular
        titleLabel.textColor = .textPrimary

        descriptionLabel.text = Loc.Alert.TemplatesAvailable.description
        descriptionLabel.font = .relation3Regular
        descriptionLabel.textColor = .textSecondary

        button.setTitle(Loc.Alert.TemplatesAvailable.button, for: .normal)
        button.setTitleColor(.textPrimary, for: .normal)
        button.titleLabel?.font = .calloutRegular
        button.widthAnchor.constraint(equalToConstant: 80).isActive = true
        button.heightAnchor.constraint(equalToConstant: 36).isActive = true
        button.dynamicBorderColor = UIColor.strokePrimary
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
