import UIKit

final class ObjectRelationViewUIKit: UIView {
    let option: Relation.Object.Option
    let relationStyle: RelationStyle

    private var textView: AnytypeLabel!

    init(options: Relation.Object.Option, relationStyle: RelationStyle) {
        self.option = options
        self.relationStyle = relationStyle

        super.init(frame: .zero)

        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        CGSize(
            width: textView.intrinsicContentSize.width + relationStyle.objectRelationStyle.size.width + relationStyle.objectRelationStyle.hSpaсingObject,
            height: textView.intrinsicContentSize.height
        )
    }

    private func setupView() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = relationStyle.objectRelationStyle.hSpaсingObject

        textView = AnytypeLabel(style: relationStyle.font)
        textView.setText(option.title)
        textView.setLineBreakMode(.byTruncatingTail)
        textView.textColor = option.isDeleted ? .textTertiary : relationStyle.uiKitFontColor

        let model = ObjectIconImageModel(
            iconImage: option.icon,
            usecase: .mention(.body)
        )
        let icon = ObjectIconImageView()
        icon.configure(model: model)

        stackView.addArrangedSubview(icon)
        stackView.addArrangedSubview(textView)

        icon.layoutUsing.anchors {
            $0.width.equal(to: relationStyle.objectRelationStyle.size.width)
            $0.height.equal(to: relationStyle.objectRelationStyle.size.height, priority: .defaultHigh)
        }

        addSubview(stackView) {
            $0.pinToSuperview()
        }
    }
}
