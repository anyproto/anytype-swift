import UIKit
import AnytypeCore

final class TextBlockLeadingView: UIView {

    private(set) var titleView: UIView?
    private(set) var toogleView: UIView?
    private(set) var checkboxView: UIView?
    private(set) var numberedView: UIView?
    private(set) var bulletedView: UIView?
    private(set) var quoteView: UIView?
    private(set) var calloutIconView: UIView?
    
    private var currentStyle: TextBlockLeadingStyle?

    func update(style: TextBlockLeadingStyle) {
        guard currentStyle != style else { return }
        
        removeAllSubviews()
        isHidden = false
        
        currentStyle = style

        let innerView: UIView
        switch style {
        case .title(let titleModel):
            guard titleModel.isCheckable else {
                isHidden = true
                return
            }
            innerView = TextBlockLeadingViewBuilder.checkableLeftTitleView(model: titleModel)
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
            isHidden = true
            return
        case .callout(let model):
            innerView = TextBlockIconView(
                viewType: .callout(image: model.icomImage),
                action: model.onTap
            )
            self.calloutIconView = innerView

            addSubview(innerView) {
                $0.height.equal(to: 20)
                $0.width.equal(to: 20)

                $0.pinToSuperview(
                    excluding: [.bottom],
                    insets: .init(
                        top: 2,
                        left: 12,
                        bottom: 0,
                        right: 6 // 12 subtract contentStackView horizontal spacing
                    )
                )
            }

            let action = UIAction { _ in model.onTap() }

            let button = UIButton()
            button.addAction(action, for: .touchUpInside)

            addSubview(button) {
                $0.pinToSuperview()
            }

            return
        }

        addSubview(innerView) {
            $0.pinToSuperview(excluding: [.bottom])
            $0.bottom.equal(to: bottomAnchor, priority: .defaultLow)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
