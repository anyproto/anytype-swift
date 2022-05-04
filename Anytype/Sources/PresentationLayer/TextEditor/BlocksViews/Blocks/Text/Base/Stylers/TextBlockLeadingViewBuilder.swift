import UIKit

final class TextBlockLeadingViewBuilder {
    static func leftTitleView(model: TextBlockLeadingStyle.TitleModel) -> UIView {
        guard model.isCheckable else {
            return TextBlockIconView(viewType: .empty)
        }

        return TextBlockIconView(viewType: .titleCheckbox(isSelected: model.checked)) {
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            model.toggleAction()
        }
    }

    static func leftToggleView(model: TextBlockLeadingStyle.ToggleModel) -> UIView {
        TextBlockIconView(viewType: .toggle(toggled: model.isToggled), action: model.toggleAction)
    }

    static func leftCheckboxView(model: TextBlockLeadingStyle.CheckboxModel) -> UIView {
        TextBlockIconView(viewType: .checkbox(isSelected: model.isChecked)) {
            UISelectionFeedbackGenerator().selectionChanged()
            model.toggleAction()
        }
    }
}
