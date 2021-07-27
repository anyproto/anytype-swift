
import UIKit


enum ButtonsFactory {
    typealias ActionHandler = (_ action: UIAction) -> Void

    private enum Constants {
        static let backButtonImageToTitlePadding: CGFloat = 10
    }
    
    static func makeBackButton(actionHandler: @escaping ActionHandler) -> UIButton {
        let backButton = UIButton(type: .system, primaryAction: UIAction { action in
            actionHandler(action)
        })
        backButton.setAttributedTitle(
            NSAttributedString(
                string: "Back".localized,
                attributes: [.font: UIFont.caption]
            ),
            for: .normal
        )
        backButton.setImage(.back, for: .normal)
        backButton.setImageAndTitleSpacing(Constants.backButtonImageToTitlePadding)
        backButton.tintColor = .secondaryTextColor
        return backButton
    }
    
    static func makeRoundedButton(
        image: UIImage?,
        target: Any,
        selector: Selector,
        stateFlag: Bool?) -> ButtonWithImage {
        let button = roundedBorderуButton(image: image)
        if let flag = stateFlag {
            button.isSelected = flag
        } else {
            button.isEnabled = false
        }
        button.addTarget(target, action: selector, for: .touchUpInside)
        return button
    }

    static func roundedBorderуButton(image: UIImage?) -> ButtonWithImage {
        let button = ButtonWithImage()
        button.setImage(image)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.grayscale30.cgColor
        button.contentMode = .center
        button.imageView.contentMode = .scaleAspectFit

        return button
    }
}
