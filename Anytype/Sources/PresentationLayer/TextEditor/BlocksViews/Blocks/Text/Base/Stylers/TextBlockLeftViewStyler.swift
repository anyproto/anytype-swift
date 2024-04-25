import UIKit
import Services

@MainActor
final class TextBlockLeftViewStyler {
    static func applyStyle(
        contentStackView view: UIStackView,
        configuration: TextBlockContentConfiguration
    ) {
        updateIconSpacing(contentStackView: view, configuration: configuration)
    }
    
    private static func updateIconSpacing(contentStackView: UIStackView, configuration: TextBlockContentConfiguration) {
        if configuration.content.contentType == .title, configuration.isCheckable {
            contentStackView.spacing = 8
        } else {
            contentStackView.spacing = 4
        }
    }
}
