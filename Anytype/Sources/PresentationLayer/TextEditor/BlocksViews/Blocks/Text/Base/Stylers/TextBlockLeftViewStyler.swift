import UIKit
import BlocksModels

final class TextBlockLeftViewStyler {
    static func applyStyle(
        contentStackView view: UIStackView,
        style: BlockText.Style,
        isCheckable: Bool,
        isToggled: Bool,
        content: BlockText,
        onTitleTap: @escaping () -> (),
        onCheckboxTap: @escaping () -> (),
        onToggleTap: @escaping () -> ()
    ) {
        updateIconSpacing(contentStackView: view, style: style, isCheckable: isCheckable)
        
        let leftView: UIView
        
        switch style {
        case .title:
            leftView = leftTitleView(isCheckable: isCheckable, isChecked: content.checked, onTap: onTitleTap)
        case .toggle:
            leftView = TextBlockIconView(viewType: .toggle(toggled: isToggled), action: onToggleTap)
        case .bulleted:
            leftView = TextBlockIconView(viewType: .bulleted)            
        case .checkbox:
            leftView = TextBlockIconView(viewType: .checkbox(isSelected: content.checked), action: onCheckboxTap)
        case .numbered:
            leftView = TextBlockIconView(viewType: .numbered(content.number))
        case .quote:
            leftView = TextBlockIconView(viewType: .quote)
        case .header, .header2, .header3, .header4, .code, .description, .text:
            leftView = TextBlockIconView(viewType: .empty)
        }
        
        view.arrangedSubviews.first?.removeFromSuperview()
        view.insertArrangedSubview(leftView, at: 0)
    }
    
    private static func updateIconSpacing(contentStackView: UIStackView, style: BlockText.Style, isCheckable: Bool) {
        if style == .title, isCheckable {
            contentStackView.spacing = 8
        } else {
            contentStackView.spacing = 4
        }
    }
    
    private static func leftTitleView(isCheckable: Bool, isChecked: Bool, onTap: @escaping () -> ()) -> UIView {
        guard isCheckable else {
            return TextBlockIconView(viewType: .empty)
        }

        return TextBlockIconView(viewType: .titleCheckbox(isSelected: isChecked), action: onTap)
    }
}
