import UIKit


@MainActor
enum ButtonsFactory {
    typealias ActionHandler = (_ action: UIAction) -> Void
    
    static func makeButton(image: UIImage? = nil, text: String? = nil, textStyle: ButtonWithImage.TextStyle = .default) -> ButtonWithImage {
        let button = ButtonWithImage(textStyle: textStyle)
        button.setImage(image)
        button.setText(text ?? "")
        button.setBackgroundColor(.Background.secondary, state: .normal)
        button.setForegroundColor(.clear, state: .normal)
        button.setForegroundColor(.clear, state: .disabled)
        button.setForegroundColor(.Background.highlightedMedium, state: .selected)
        button.setImageTintColor(.Control.tertiary, state: .disabled)
        button.setImageTintColor(.Text.primary, state: .normal)

        return button
    }

    static func roundedBorderуButton(image: UIImage?) -> ButtonWithImage {
        let button = makeButton(image: image)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.dynamicBorderColor = UIColor.Shape.primary
        button.contentMode = .center
        button.imageView.contentMode = .scaleAspectFit

        return button
    }
}
