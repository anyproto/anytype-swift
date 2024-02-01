import UIKit


extension ChangeTypeAccessoryView {
    final class ChangeButton: UIButton {
        override init(frame: CGRect) {
            super.init(frame: frame)

            setup()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)

            setup()
        }

        private func setup() {
            var configuration = UIButton.Configuration.plain()
            configuration.attributedTitle = attributedString(for: .normal)
            configuration.image = UIImage(asset: .X18.listArrow)
            configuration.buttonSize = .mini
            configuration.titleAlignment = .leading
            configuration.imagePlacement = .trailing
            configuration.imagePadding = 4
            self.configuration = configuration
            
            configurationUpdateHandler = { [weak self] button in
                guard let self = self else { return }
                
                var configuration = button.configuration
                configuration?.attributedTitle = attributedString(for: button.state)
                self.configuration = configuration
            }
        }
        
        private func attributedString(for state: UIButton.State) -> AttributedString {
            .init(
                Loc.changeType,
                attributes: AttributeContainer([
                    NSAttributedString.Key.font: UIFont.calloutRegular,
                    NSAttributedString.Key.foregroundColor: state == .highlighted ? UIColor.Text.primary : UIColor.Text.secondary
                ])
            )
        }
    }
}

extension ChangeTypeAccessoryView {
    func createDoneButton() -> UIButton {
        let button = UIButton(type: .custom)
        let primaryAction = UIAction { [weak self] _ in
            self?.viewModel.handleDoneButtonTap()
        }

        button.setTitle(Loc.done, for: .normal)
        button.setTitleColor(UIColor.Text.primary, for: .normal)
        button.addAction(primaryAction, for: .touchUpInside)

        return button
    }
}
