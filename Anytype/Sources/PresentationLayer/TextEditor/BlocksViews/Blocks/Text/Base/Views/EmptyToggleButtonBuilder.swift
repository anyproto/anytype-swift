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
        
        var configuration = UIButton.Configuration.plain()
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 28, bottom: 0, trailing: 0)
        button.configuration = configuration
        
        return button
    }
}
