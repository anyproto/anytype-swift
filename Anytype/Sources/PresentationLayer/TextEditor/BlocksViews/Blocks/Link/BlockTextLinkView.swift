import UIKit

final class BlockTextLinkView: UIView, BlockContentView {
    private let titleLabel = AnytypeLabel(style: .previewTitle1Medium)
    private let descriptionLabel = AnytypeLabel(style: .relation3Regular)
    private let objectTypeLabel = AnytypeLabel(style: .relation3Regular)
    private let taskButton = UIButton()

    private let stackView = UIStackView()

    private var onTaskActionTap: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupSubviews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupSubviews()
    }

    func update(with configuration: BlockLinkTextConfiguration) {
        configuration.state.applyTitleState(
            on: titleLabel,
            font: .previewTitle1Medium
        )

        descriptionLabel.isHidden = configuration.state.description.isEmpty
        descriptionLabel.setText(configuration.state.attributedDescription)

        objectTypeLabel.isHidden = !configuration.state.relations.contains(.type)
        objectTypeLabel.setText(configuration.state.attributedType)

        [descriptionLabel, objectTypeLabel].forEach {
            if configuration.state.archived || configuration.state.deleted {
                $0.isHidden = true
            }
        }

        onTaskActionTap = configuration.todoToggleAction
        taskButton.isHidden = configuration.state.objectLayout != .todo
    }

    @objc
    private func taskButtonAction() {
        onTaskActionTap?()
    }

    private func setupSubviews() {
        taskButton.addTarget(self, action: #selector(taskButtonAction), for: .touchUpInside)
        setupLayout()

        titleLabel.numberOfLines = 3
        descriptionLabel.numberOfLines = 2
        objectTypeLabel.numberOfLines = 1

        stackView.axis = .vertical
        stackView.spacing = 4
    }

    private func setupLayout() {
        addSubview(stackView) {
            $0.pinToSuperview(insets: .init(top: 1, left: 4, bottom: -1, right: -4))
        }

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
        stackView.addArrangedSubview(objectTypeLabel)

        addSubview(taskButton) {
            $0.top.equal(to: titleLabel.topAnchor)
            $0.leading.equal(to: titleLabel.leadingAnchor)
            $0.width.equal(to: 24)
            $0.height.equal(to: 24)
        }
    }
}
