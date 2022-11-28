import UIKit

final class TagViewUIKit: UIView {
    private let relationTag: Relation.Tag.Option
    private let style: RelationStyle

    init(tag: Relation.Tag.Option, style: RelationStyle) {
        self.relationTag = tag
        self.style = style

        super.init(frame: .zero)

        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var textView: AnytypeLabel!


    override var intrinsicContentSize: CGSize {
        CGSize(width: textView.intrinsicContentSize.width + style.tagViewGuidlines.textPadding * 2, height: textView.intrinsicContentSize.height)
    }

    private func setupView() {
        backgroundColor = relationTag.backgroundColor

        layer.cornerCurve = .continuous
        layer.cornerRadius = style.tagViewGuidlines.cornerRadius
        
        textView = AnytypeLabel(style: style.font)
        textView.setText(relationTag.text)
        textView.textColor = relationTag.textColor

        textView.setLineBreakMode(.byTruncatingTail)

        addSubview(textView) {
            $0.pinToSuperview(insets: UIEdgeInsets(top: 0, left: style.tagViewGuidlines.textPadding, bottom: 0, right: style.tagViewGuidlines.textPadding))
            $0.height.equal(to: style.tagViewGuidlines.tagHeight, priority: .defaultHigh)
        }
    }
}
