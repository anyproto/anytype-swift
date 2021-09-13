import UIKit

final class EmptyToggleButtonBuilder {
    static func create(onTap: @escaping () -> ()) -> UIButton {
        let button = UIButton(
            primaryAction: UIAction(
                handler: { _ in
                    onTap()
                }
            )
        )
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setAttributedTitle(
            .init(
                string: "Toggle empty. Tap to create block.".localized,
                attributes: [
                    .font: UIFont.bodyRegular,
                    .foregroundColor: UIColor.textSecondary
                ]
            ),
            for: .normal
        )
        button.contentHorizontalAlignment = .leading
        button.isHidden = true
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 28, bottom: 0, right: 0)
        button.titleLabel?.lineBreakMode = .byWordWrapping
        
        return button
    }
}
