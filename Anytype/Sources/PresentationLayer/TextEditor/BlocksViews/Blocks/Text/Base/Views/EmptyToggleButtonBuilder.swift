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
                string: Loc.ToggleEmpty.tapToCreateBlock,
                attributes: [
                    .font: UIFont.bodyRegular,
                    .foregroundColor: UIColor.Text.secondary
                ]
            ),
            for: .normal
        )
        button.contentHorizontalAlignment = .leading
        button.isHidden = true
        button.titleLabel?.lineBreakMode = .byWordWrapping
        
        if #available(iOS 15.0, *) {
            var configuration = UIButton.Configuration.plain()
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 28, bottom: 0, trailing: 0)
            button.configuration = configuration
        } else {
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 28, bottom: 0, right: 0)
        }
        
        return button
    }
}
