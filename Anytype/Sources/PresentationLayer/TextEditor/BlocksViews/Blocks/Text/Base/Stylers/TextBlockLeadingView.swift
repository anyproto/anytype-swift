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
