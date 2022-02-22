import UIKit

final class TagViewUIKit: UIView {
    let relationTag: Relation.Tag.Option
    let guidlines: TagView.Guidlines

    init(tag: Relation.Tag.Option, guidlines: TagView.Guidlines) {
        self.relationTag = tag
        self.guidlines = guidlines

        super.init(frame: .zero)

        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var textView: AnytypeLabel!


    override var intrinsicContentSize: CGSize {
        CGSize(width: textView.intrinsicContentSize.width + guidlines.textPadding * 2, height: textView.intrinsicContentSize.height)
    }

    private func setupView() {
        backgroundColor = relationTag.backgroundColor

        layer.cornerCurve = .continuous
        layer.cornerRadius = guidlines.cornerRadius

        textView = AnytypeLabel(style: .relation2Regular)
        textView.setText(relationTag.text)
        textView.textColor = relationTag.textColor

        textView.setLineBreakMode(.byTruncatingTail)

        addSubview(textView) {
            $0.pinToSuperview(insets: UIEdgeInsets(top: 0, left: guidlines.textPadding, bottom: 0, right: -guidlines.textPadding))
            $0.height.equal(to: guidlines.tagHeight, priority: .defaultHigh)
        }
    }
}
