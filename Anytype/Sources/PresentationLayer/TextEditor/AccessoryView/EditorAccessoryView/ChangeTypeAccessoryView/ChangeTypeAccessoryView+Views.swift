import UIKit


extension ChangeTypeAccessoryView {
    final class ChangeButton: UIButton {
        private var isOpen = false
        
        override init(frame: CGRect) {
            super.init(frame: frame)

            setup()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)

            setup()
        }
        
        func updateState(isOpen: Bool) {
            self.isOpen = isOpen
            imageView?.transform = isOpen ? .identity : CGAffineTransform(rotationAngle: Double.pi)
            configuration?.attributedTitle = attributedString(for: state)
        }

        private func setup() {
            var configuration = UIButton.Configuration.plain()
            configuration.attributedTitle = attributedString(for: .normal)
            configuration.image = UIImage(asset: .X18.listArrow)?
                .withTintColor(.Text.secondary, renderingMode: .alwaysOriginal)
            
            configuration.buttonSize = .mini
            configuration.titleAlignment = .leading
            configuration.imagePlacement = .trailing
            configuration.imagePadding = 4
            self.configuration = configuration
            
            configurationUpdateHandler = { [weak self] button in
                guard let self = self else { return }
                
                var configuration = button.configuration
                
                configuration?.attributedTitle = attributedString(for: button.state)
                
                if let image = configuration?.image {
                    let color: UIColor = button.state == .highlighted ? .Text.tertiary : .Text.secondary
                    configuration?.image = image.withTintColor(color)
                }
                
                self.configuration = configuration
            }
        }
        
        private func attributedString(for state: UIButton.State) -> AttributedString {
            .init(
                isOpen ? Loc.hideTypes : Loc.showTypes,
                attributes: AttributeContainer([
                    NSAttributedString.Key.font: UIFont.calloutRegular,
                    NSAttributedString.Key.foregroundColor: state == .highlighted ? UIColor.Text.tertiary : UIColor.Text.secondary
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
        button.setTitleColor(UIColor.Text.secondary, for: .highlighted)
        
        button.addAction(primaryAction, for: .touchUpInside)

        return button
    }
}
