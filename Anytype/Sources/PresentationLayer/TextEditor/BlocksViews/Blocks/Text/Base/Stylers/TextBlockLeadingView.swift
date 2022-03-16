import UIKit

final class TextBlockLeadingView: UIView {

    private(set) var titleView: UIView?
    private(set) var toogleView: UIView?
    private(set) var checkboxView: UIView?
    private(set) var numberedView: UIView?
    private(set) var bulletedView: UIView?
    private(set) var quoteView: UIView?
    private(set) var bodyView: UIView?

    func update(style: TextBlockLeadingStyle) {
        removeAllSubviews()

        let innerView: UIView
        switch style {
        case .title(let titleModel):
            innerView = TextBlockLeadingViewBuilder.leftTitleView(model: titleModel)
            self.titleView = innerView
        case .toggle(let toggleModel):
            innerView = TextBlockLeadingViewBuilder.leftToggleView(model: toggleModel)
            self.toogleView = innerView
        case .checkbox(let checkboxModel):
            innerView = TextBlockLeadingViewBuilder.leftCheckboxView(model: checkboxModel)
            self.checkboxView = innerView
        case .numbered(let int):
            innerView = TextBlockIconView(viewType: .numbered(int))
            self.numberedView = innerView
        case .bulleted:
            innerView = TextBlockIconView(viewType: .bulleted)
            self.bulletedView = innerView
        case .quote:
            innerView = TextBlockIconView(viewType: .quote)
            self.quoteView = innerView
        case .body:
            innerView = TextBlockIconView(viewType: .empty)
            self.bodyView = innerView
        }

        addSubview(innerView) {
            $0.pinToSuperview()
        }
    }
}

private final class TextBlockLeadingViewBuilder {
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
