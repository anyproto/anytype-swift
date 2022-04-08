import UIKit
import AnytypeCore

final class TextBlockLeadingView: UIView {

    private(set) var titleView: UIView?
    private(set) var toogleView: UIView?
    private(set) var checkboxView: UIView?
    private(set) var numberedView: UIView?
    private(set) var bulletedView: UIView?
    private(set) var quoteView: UIView?
    private(set) var bodyView: UIView?
    private(set) var emojiView: UIView?
    private(set) var calloutIconView: UIView?

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
        case .callout(let model):
            innerView = TextBlockIconView(
                viewType: .callout(model: model.iconImageModel),
                action: model.onTap
            )
            self.calloutIconView = innerView

            addSubview(innerView) {
                $0.pinToSuperview(
                    excluding: [.bottom],
                    insets: .init(
                        top: 0,
                        left: 12,
                        bottom: 0,
                        right: -6 // 12 - contentStackView horizontal spaciing
                    )
                )
            }

            return
        }

        addSubview(innerView) {
            $0.pinToSuperview()
        }
    }
}
