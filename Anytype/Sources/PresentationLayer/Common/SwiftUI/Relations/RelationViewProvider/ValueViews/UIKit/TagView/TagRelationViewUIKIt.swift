import UIKit

final class TagRelationViewUIKIt: UIView {
    let tags: [Relation.Tag.Option]
    let hint: String
    let style: RelationStyle

    private lazy var textView = AnytypeLabel(style: style.font)
    private var stackView = UIStackView()

    // MARK: - Lifecycle

    init(tags: [Relation.Tag.Option], hint: String, style: RelationStyle) {
        self.tags = tags
        self.hint = hint
        self.style = style

        super.init(frame: .zero)

        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup view

    private func setupViews() {
        if tags.isEmpty {
            setupPlaceholder()
        } else {
            setupTagsView()
        }
    }

    private func setupTagsView() {
        stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 6
        stackView.distribution = .fillProportionally

        tags.prefix(Constants.maxShowingTag).forEach { tag in
            let tagView = TagViewUIKit(tag: tag, style: style)
            stackView.addArrangedSubview(tagView)
        }
        stackView.arrangedSubviews.first?.setContentCompressionResistancePriority(.required, for: .horizontal)

        // add more tags view
        if tags.count > Constants.maxShowingTag {
            let count = tags.count - Constants.maxShowingTag
            let moreTags = Relation.Tag.Option(id: "",
                                               text: "+\(count)",
                                               textColor: .TextNew.secondary,
                                               backgroundColor: .strokeTransperent)
            let moreTagsView = TagViewUIKit(tag: moreTags, style: style)
            moreTagsView.setContentCompressionResistancePriority(.required + 1, for: .horizontal)
            stackView.addArrangedSubview(moreTagsView)
        }

        addSubview(stackView) {
            $0.pinToSuperview(excluding: [.right])
            $0.trailing.lessThanOrEqual(to: trailingAnchor)
        }
    }

    private func setupPlaceholder() {
        let placeholder = RelationPlaceholderViewUIKit(hint: hint, style: style)

        addSubview(placeholder) {
            $0.pinToSuperview()
        }

    }
}

extension TagRelationViewUIKIt {
    enum Constants {
        static let maxShowingTag = 1
    }
}
