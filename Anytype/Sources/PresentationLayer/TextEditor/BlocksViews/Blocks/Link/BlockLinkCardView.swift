import UIKit
import BlocksModels
import Kingfisher
import AnytypeCore

final class BlockLinkCardView: UIView, BlockContentView {
    
    // MARK: - Views

    private let coverView = BlockLinkCoverView()
    private let largeLeadingIconImageView = ObjectIconImageView()

    private let titleLabel = AnytypeLabel(style: .uxTitle2Medium)
    private let descriptionLabel = AnytypeLabel(style: .relation3Regular)
    private let objectTypeLabel = AnytypeLabel(style: .relation3Regular)
    private let taskButton = UIButton()

    private let mainVerticalStackView = UIStackView()
    private let verticalTextsStackView = UIStackView()
    private let horizontalContentStackView = UIStackView()

    private var topPaddingConstraint: NSLayoutConstraint?
    private var largeLeadingIconImageViewHeightConstraint: NSLayoutConstraint?
    private var verticalTextsStackViewHeightConstraint: NSLayoutConstraint?

    private var onTaskActionTap: (() -> Void)?
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }

    // MARK: - Configuration updates

    func update(with configuration: BlockLinkCardConfiguration) {
        configuration.state.applyTitleState(
            on: titleLabel,
            font: configuration.state.textTitleFont,
            iconIntendHidden: configuration.state.iconSize == .medium
        )


        descriptionLabel.isHidden = configuration.state.description.isEmpty
        descriptionLabel.setText(configuration.state.description)

        objectTypeLabel.isHidden = !configuration.state.relations.contains(.type)
        configuration.state.type.map { objectTypeLabel.setText($0.name) }

        configuration.state.iconImage.map {
            largeLeadingIconImageView.configure(model: .init(iconImage: $0, usecase: .linkToObject))
        }

        onTaskActionTap = configuration.todoToggleAction

        setupElementsVisibility(with: configuration)
    }

    @objc
    private func taskButtonAction() {
        onTaskActionTap?()
    }

    private func setupElementsVisibility(with configuration: Configuration) {
        let hasCover = configuration.state.documentCover != nil && configuration.state.relations.contains(.cover)

        switch (configuration.state.style, configuration.state.iconImage, configuration.state.iconSize, hasCover) {
        case (.checkmark, _, _, _), (_, .none, _, _):
            setLargeLeadingIconImageViewHidden(true)
        case (_, .some(_), .medium, false):
            setLargeLeadingIconImageViewHidden(false)
        default:
            setLargeLeadingIconImageViewHidden(true)
        }

        switch configuration.state.documentCover {
        case let .some(documentCover):
            horizontalContentStackView.directionalLayoutMargins = .init(
                top: 0,
                leading: 16,
                bottom: 0,
                trailing: 16
            )

            coverView.isHidden = false

            let cover = ObjectHeaderCover(coverType: .cover(documentCover), onTap: {})

            let hasCoverIcon = configuration.state.iconSize == .medium && configuration.state.iconImage != nil
            switch (hasCoverIcon, configuration.state.style) {
            case (true, .icon(let iconType)):
                coverView.configure(
                    state: .iconAndCover(
                        icon: .init(
                            icon: .init(mode: .icon(iconType), usecase: .linkToObject),
                            layoutAlignment: .left,
                            onTap: {}
                        ),
                        cover: cover
                    )
                )
            default:
                coverView.configure(state: .coverOnly(cover))
            }
        default:
            horizontalContentStackView.directionalLayoutMargins = .init(
                top: 16,
                leading: 16,
                bottom: 0,
                trailing: 16
            )

            coverView.isHidden = true
        }

        taskButton.isHidden = configuration.state.objectLayout != .todo
    }

    // MARK: - Private functions
    
    private func setLargeLeadingIconImageViewHidden(_ isHidden: Bool) {
        largeLeadingIconImageView.isHidden = isHidden
        largeLeadingIconImageViewHeightConstraint?.constant = isHidden ? 0 : 48
        verticalTextsStackViewHeightConstraint?.isActive = !isHidden
    }

    private func setupSubviews() {
        taskButton.addTarget(self, action: #selector(taskButtonAction), for: .touchUpInside)
        setupLayout()

        layer.cornerRadius = 12
        layer.masksToBounds = true
        layer.borderColor = UIColor.strokeTransperent.cgColor
        layer.borderWidth = 1.0

        titleLabel.numberOfLines = 2
        titleLabel.setLineBreakMode(.byTruncatingTail)

        descriptionLabel.numberOfLines = 2
        objectTypeLabel.numberOfLines = 1

        objectTypeLabel.textColor = .textSecondary
    }

    private func setupLayout() {
        mainVerticalStackView.axis = .vertical
        mainVerticalStackView.distribution = .fill

        verticalTextsStackView.axis = .vertical
        verticalTextsStackView.spacing = 2
        verticalTextsStackView.distribution = .fill

        horizontalContentStackView.axis = .horizontal
        horizontalContentStackView.distribution = .fill
        horizontalContentStackView.alignment = .top
        horizontalContentStackView.spacing = 12
        horizontalContentStackView.directionalLayoutMargins = .init(
            top: 0,
            leading: 16,
            bottom: 0,
            trailing: 16
        )
        horizontalContentStackView.isLayoutMarginsRelativeArrangement = true

        mainVerticalStackView.addArrangedSubview(coverView)
        mainVerticalStackView.addArrangedSubview(horizontalContentStackView)

        verticalTextsStackView.addArrangedSubview(titleLabel)
        verticalTextsStackView.addArrangedSubview(descriptionLabel)
        verticalTextsStackView.addArrangedSubview(objectTypeLabel)
        
        let verticalWrapperStackView = UIStackView()
        verticalWrapperStackView.alignment = .center
        verticalWrapperStackView.distribution = .equalSpacing
        verticalWrapperStackView.axis = .vertical
        
        verticalWrapperStackView.addArrangedSubview(UIView())
        verticalWrapperStackView.addArrangedSubview(verticalTextsStackView)
        verticalWrapperStackView.addArrangedSubview(UIView())
        
        largeLeadingIconImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        largeLeadingIconImageViewHeightConstraint = largeLeadingIconImageView.heightAnchor.constraint(equalToConstant: 48)
        largeLeadingIconImageViewHeightConstraint?.isActive = true

        horizontalContentStackView.addArrangedSubview(largeLeadingIconImageView)
        horizontalContentStackView.addArrangedSubview(verticalWrapperStackView)

        addSubview(mainVerticalStackView) {
            $0.pinToSuperview(insets: .init(top: 0, left: 0, bottom: 16, right: 0))
        }

        addSubview(taskButton) {
            $0.top.equal(to: titleLabel.topAnchor)
            $0.leading.equal(to: titleLabel.leadingAnchor)
            $0.width.equal(to: 24)
            $0.height.equal(to: 24)
        }
            
        verticalTextsStackViewHeightConstraint = verticalWrapperStackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 48)
        verticalTextsStackViewHeightConstraint?.isActive = true
        verticalTextsStackViewHeightConstraint?.priority = .defaultHigh
    }
}

private final class BlockLinkCoverView: UIView {
    typealias State = ObjectHeaderView.State

    // MARK: - Private variables

    private let iconView = ObjectHeaderIconView()
    private let coverView = ObjectHeaderCoverView()

    private var coverBottomConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupView()
    }

    private func setupView() {
        backgroundColor = .BackgroundNew.primary

        setupLayout()

        iconView.initialBorderWidth = 2

        iconView.isHidden = true
        coverView.isHidden = true
    }


    private func setupLayout() {
        addSubview(coverView) {
            $0.pinToSuperview(excluding: [.bottom])
            $0.height.equal(to: 136)
            coverBottomConstraint = $0.bottom.equal(to: bottomAnchor, constant: -24)
        }

        addSubview(iconView) {
            $0.leading.equal(to: leadingAnchor, constant: 16)
            $0.top.equal(to: coverView.bottomAnchor, constant: -32)
        }
    }
}

extension BlockLinkCoverView {
    func configure(state: ObjectHeaderFilledState) {
        switch state {
        case .iconOnly(let objectHeaderIconState):
            switchState(.icon)
            applyObjectHeaderIcon(objectHeaderIconState.icon)
        case .coverOnly(let objectHeaderCover):
            switchState(.cover)

            applyObjectHeaderCover(objectHeaderCover, maxWidth: 320)

        case .iconAndCover(let objectHeaderIcon, let objectHeaderCover):
            switchState(.iconAndCover)

            applyObjectHeaderIcon(objectHeaderIcon)
            applyObjectHeaderCover(objectHeaderCover, maxWidth: 320)
        }
    }

    private func applyObjectHeaderCover(
        _ objectHeaderCover: ObjectHeaderCover,
        maxWidth: CGFloat
    ) {
        coverView.configure(
            model: ObjectHeaderCoverView.Model(
                objectCover: objectHeaderCover.coverType,
                size: CGSize(
                    width: maxWidth,
                    height: 136
                ),
                fitImage: false
            )
        )
    }

    private func applyObjectHeaderIcon(_ objectHeaderIcon: ObjectHeaderIcon) {
        iconView.configure(model: objectHeaderIcon.icon)
    }

    private func switchState(_ state: State) {
        switch state {
        case .icon:
            anytypeAssertionFailure("Wrong case", domain: .blockValidator)
        case .cover:
            iconView.isHidden = true
            coverView.isHidden = false

            coverBottomConstraint?.constant = -12
        case .iconAndCover:
            iconView.isHidden = false
            coverView.isHidden = false
            coverBottomConstraint?.constant = -24
        }
    }
}
