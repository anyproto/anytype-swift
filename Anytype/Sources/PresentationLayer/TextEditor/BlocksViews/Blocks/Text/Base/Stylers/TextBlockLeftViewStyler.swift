import UIKit
import BlocksModels

final class TextBlockLeftViewStyler {
    static func applyStyle(
        contentStackView view: UIStackView,
        configuration: TextBlockContentConfiguration
    ) {
        updateIconSpacing(contentStackView: view, configuration: configuration)
        
        let leftView: UIView
        
        switch configuration.content.contentType {
        case .title:
            leftView = leftTitleView(configuration: configuration)
        case .toggle:
            leftView = leftToggleView(configuration: configuration)
        case .bulleted:
            leftView = TextBlockIconView(viewType: .bulleted)            
        case .checkbox:
            leftView = leftCheckboxView(configuration: configuration)
        case .numbered:
            leftView = TextBlockIconView(viewType: .numbered(configuration.content.number))
        case .quote:
            leftView = TextBlockIconView(viewType: .quote)
        case .header, .header2, .header3, .header4, .code, .description, .text:
            leftView = TextBlockIconView(viewType: .empty)
        }
        
        view.arrangedSubviews.first?.removeFromSuperview()
        view.insertArrangedSubview(leftView, at: 0)
    }
    
    private static func updateIconSpacing(contentStackView: UIStackView, configuration: TextBlockContentConfiguration) {
        if configuration.content.contentType == .title, configuration.isCheckable {
            contentStackView.spacing = 8
        } else {
            contentStackView.spacing = 4
        }
    }
    
    private static func leftTitleView(configuration: TextBlockContentConfiguration) -> UIView {
        guard configuration.isCheckable else {
            return TextBlockIconView(viewType: .empty)
        }

        return TextBlockIconView(viewType: .titleCheckbox(isSelected: configuration.content.checked)) {
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            configuration.actions.toggleCheckBox()
         }
    }
    
    private static func leftToggleView(configuration: TextBlockContentConfiguration) -> UIView {
        TextBlockIconView(viewType: .toggle(toggled: configuration.isToggled)) {
            configuration.actions.toggleDropDown()
        }
    }
    
    private static func leftCheckboxView(configuration: TextBlockContentConfiguration) -> UIView {
        TextBlockIconView(viewType: .checkbox(isSelected: configuration.content.checked)) {
            UISelectionFeedbackGenerator().selectionChanged()
            configuration.actions.toggleCheckBox()
        }
    }
}
