
import UIKit


enum ButtonsFactory {
    typealias ActionHandler = (_ action: UIAction) -> Void
    
    static func makeBackButton(actionHandler: @escaping ActionHandler) -> UIButton {
        let backButton = UIButton(type: .system, primaryAction: UIAction { action in
            actionHandler(action)
        })
        backButton.setAttributedTitle(
            NSAttributedString(
                string: Loc.back,
                attributes: [.font: UIFont.caption1Regular]
            ),
            for: .normal
        )
        backButton.setImage(UIImage(asset: .backArrow), for: .normal)
        backButton.tintColor = .TextNew.secondary
        
        if #available(iOS 15.0, *) {
            var configuration = UIButton.Configuration.borderless()
            configuration.imagePadding = 10
            backButton.configuration = configuration
        } else {
            backButton.imageEdgeInsets = UIEdgeInsets(
                top: backButton.imageEdgeInsets.top,
                left: backButton.imageEdgeInsets.left,
                bottom: backButton.imageEdgeInsets.bottom,
                right: 10
            )
        }
        
        return backButton
    }
    
    static func makeButton(image: UIImage? = nil, text: String? = nil, textStyle: ButtonWithImage.TextStyle = .default) -> ButtonWithImage {
        let button = ButtonWithImage(textStyle: textStyle)
        button.setImage(image)
        button.setText(text ?? "")
        button.setBackgroundColor(.clear, state: .normal)
        button.setBackgroundColor(.clear, state: .disabled)
        button.setBackgroundColor(.BackgroundNew.highlightedOfSelected, state: .selected)
        button.setImageTintColor(.Button.inactive, state: .disabled)
        button.setImageTintColor(.TextNew.primary, state: .normal)

        return button
    }

    static func roundedBorderуButton(image: UIImage?) -> ButtonWithImage {
        let button = makeButton(image: image)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.dynamicBorderColor = UIColor.Stroke.primary
        button.contentMode = .center
        button.imageView.contentMode = .scaleAspectFit

        return button
    }
}
