import UIKit

final class FileListRelationViewUIKit: UIView {
    let options: [Relation.File.Option]
    let hint: String
    let style: RelationStyle

    private lazy var textView = AnytypeLabel(style: style.font)
    private var stackView = UIStackView()

    // MARK: - Lifecycle

    init(options: [Relation.File.Option], hint: String, style: RelationStyle) {
        self.options = options
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
        if options.isEmpty {
            setupPlaceholder()
        } else {
            setupObjectsView()
        }
    }

    private func setupObjectsView() {
        stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 6

        options.prefix(Constants.maxShowingOptions).forEach { option in
            let fileView = FileRelationViewUIKit(options: option,
                                                   objectRelationStyle: style.objectRelationStyle)
            stackView.addArrangedSubview(fileView)
        }
        stackView.arrangedSubviews.first?.setContentCompressionResistancePriority(.required, for: .horizontal)

        // add more view
        if options.count > Constants.maxShowingOptions {
            let count = options.count - Constants.maxShowingOptions
            let moreObjectsView = MoreRelationView(count: count)
            moreObjectsView.setContentCompressionResistancePriority(.required + 1, for: .horizontal)
            stackView.addArrangedSubview(moreObjectsView)
        }

        addSubview(stackView) {
            $0.pinToSuperview(excluding: [.right])
            $0.trailing.lessThanOrEqual(to: trailingAnchor)
        }
    }

    private func setupPlaceholder() {
        let placeholder = RelationPlaceholderViewUIKit(hint: hint, type: style.placeholderType)

        addSubview(placeholder) {
            $0.pinToSuperview()
        }

    }
}

extension FileListRelationViewUIKit {
    enum Constants {
        static let maxShowingOptions = 1
    }
}
