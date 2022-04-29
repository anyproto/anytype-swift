import UIKit
import BlocksModels

final class EditorContentView<View: BlockContentView>: UIView & UIContentView, UIDragInteractionDelegate {
    typealias Configuration = CellBlockConfiguration<View.Configuration>

    var configuration: UIContentConfiguration {
        get {
            Configuration(
                blockConfiguration: blockConfiguration,
                currentConfigurationState: currentConfigurationState,
                indentationSettings: indentationSettings,
                dragConfiguration: dragConfiguration
            )
        }
        set {
            guard let newConfiguration = newValue as? Configuration else { return }

            if newConfiguration.blockConfiguration != blockConfiguration {
                blockConfiguration = newConfiguration.blockConfiguration
            }

            if newConfiguration.currentConfigurationState != currentConfigurationState {
                currentConfigurationState = newConfiguration.currentConfigurationState
            }

            if newConfiguration.indentationSettings != indentationSettings {
                indentationSettings = newConfiguration.indentationSettings
            }

            dragConfiguration = newConfiguration.dragConfiguration

            updateIndentationPaddings()
        }
    }

    private var blockConfiguration: View.Configuration {
        didSet {
            blockView.update(with: blockConfiguration)
        }
    }

    private var indentationSettings: IndentationSettings? {
        didSet {
            indentationSettings.map(update(with:))
        }
    }

    private var dragConfiguration: BlockDragConfiguration? {
        didSet {
            setupDragInteraction()
        }
    }

    private var currentConfigurationState: UICellConfigurationState? {
        didSet {
            currentConfigurationState.map {
                update(with: $0)
                blockView.update(with: $0)
            }
        }
    }

    private lazy var backgroundColorsStackView = UIStackView()
    private lazy var wrapperView = UIView()

    private lazy var contentStackView = UIView()
    private lazy var leadingView = TextBlockIconView(viewType: .quote)
    private lazy var blockView = View(frame: .zero)

    private lazy var selectionView = BaseSelectionView()
    
    private lazy var indentationViews = [UIView]()

    private var leadingViewWidthConstraint: NSLayoutConstraint?
    private var leadingViewBottomConstraint: NSLayoutConstraint?
    private var contentConstraints: InsetConstraints?
    private lazy var calloutClosingView = UIView()

    private lazy var viewDragInteraction = UIDragInteraction(delegate: self)

    init(configuration: Configuration) {
        self.blockConfiguration = configuration.blockConfiguration
        self.currentConfigurationState = configuration.currentConfigurationState
        self.indentationSettings = configuration.indentationSettings
        self.dragConfiguration = configuration.dragConfiguration

        super.init(frame: .zero)

        setupSubviews()

        blockView.update(with: configuration.blockConfiguration)
        configuration.currentConfigurationState.map { blockView.update(with: $0) }
        indentationSettings.map(update(with:))

        setupDragInteraction()
        updateIndentationPaddings()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UICollectionView configuration

    private func update(with state: UICellConfigurationState) {
        selectionView.updateStyle(isSelected: state.isSelected)

        isUserInteractionEnabled = state.isEditing
        viewDragInteraction.isEnabled = !state.isLocked
        if state.isMoving {
            backgroundColor = UIColor.Background.blue
        } else {
            backgroundColor = .clear
        }
    }

    // MARK: - Drag&Drop

    private func setupDragInteraction() {
        guard dragConfiguration != nil, viewDragInteraction.view == nil else { return }

        viewDragInteraction.isEnabled = currentConfigurationState.map { $0.isLocked } ?? true
        contentStackView.addInteraction(viewDragInteraction)
    }

    // MARK: - Indentation

    private func updateIndentationPaddings() {
        var blockContentInsets = blockConfiguration.contentInsets
        var indentationLevel = indentationSettings?.parentBlocksInfo.count ?? 0

        let additionalIndentations = indentationSettings?
            .parentBlocksInfo
            .filter { $0.indentationStyle == .callout }
            .count ?? 0

        indentationLevel = indentationLevel + additionalIndentations

        let parentIndentaionPadding = CGFloat(indentationLevel) * IndentationConstants.indentationWidth

        blockContentInsets.left = blockContentInsets.left + parentIndentaionPadding

        contentConstraints?.update(with: blockContentInsets)
    }

    private func update(with indentationSettings: IndentationSettings) {
        backgroundColorsStackView.axis = .horizontal
        backgroundColorsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        indentationViews.forEach { $0.removeFromSuperview() }
        indentationViews.removeAll()

        configureLeadingView(with: indentationSettings.style)

        if let bottomColor = indentationSettings.bottomBackgroundColor {
            bottomColoredViewHeightConstraint?.constant = 16
            bottomColoredView.backgroundColor = bottomColor
        } else {
            bottomColoredViewHeightConstraint?.constant = 0
        }

        var leadingInset = blockConfiguration.contentInsets.left

        indentationSettings.parentBlocksInfo.enumerated().forEach {
            var backgroundWidth: CGFloat? = IndentationConstants.indentationWidth

            if $0.offset == 0 {
                backgroundWidth = blockConfiguration.contentInsets.left + IndentationConstants.indentationWidth
            } else if $0.offset == indentationSettings.parentBlocksInfo.count - 1 && indentationSettings.backgroundColor == nil {
                backgroundWidth = nil
            }

            let inset = shouldMakeAdditionalPadding(for: $0.element.indentationStyle)
            ? IndentationConstants.indentationWidth * 2
            : IndentationConstants.indentationWidth


            if case .highlighted = $0.element.indentationStyle {
                addIndentationStyleView(style: $0.element.indentationStyle, leadingPadding: leadingInset)
            }

            addBackgroundColorView(color: $0.element.color, width: backgroundWidth)

            leadingInset = leadingInset + inset
        }


        let lastBackgroundColor = indentationSettings.backgroundColor ?? indentationSettings.parentBlocksInfo.last.flatMap { $0.color }

        addBackgroundColorView(color: lastBackgroundColor, width: nil)
    }

    private func shouldMakeAdditionalPadding(for style: BlockIndentationStyle) -> Bool {
        switch style {
        case .highlighted, .none:
            return false
        case .callout:
            return true
        }
    }

    private func configureLeadingView(with style: BlockIndentationStyle) {
        switch style {
        case .highlighted(let highlightStyle):
            leadingViewWidthConstraint?.constant = IndentationConstants.indentationWidth
            leadingView.isHidden = false

            switch highlightStyle {
            case .single:
                leadingViewBottomConstraint?.constant = -IndentationConstants.leadingViewVerticalPadding
            default:
                leadingViewBottomConstraint?.constant = 0
            }

        default:
            leadingViewWidthConstraint?.constant = 0
            leadingView.isHidden = true
        }
    }

    private func addIndentationStyleView(
        style: BlockIndentationStyle,
        leadingPadding: CGFloat
    ) {
        addBlockLeadingView(with: leadingPadding, shouldTrimAtBottom: style == .highlighted(.closing))
    }

    private func addBlockLeadingView(with indentation: CGFloat, shouldTrimAtBottom: Bool) {
        let leadingView = TextBlockLeadingView()
        leadingView.update(style: .quote)

        indentationViews.append(leadingView)
        addSubview(leadingView) {
            $0.pinToSuperview(
                excluding: [.right, .bottom],
                insets: .init(
                    top: 0,
                    left: indentation,
                    bottom: 0,
                    right: 0
                )
            )

            $0.bottom.equal(
                to: contentStackView.bottomAnchor,
                constant: shouldTrimAtBottom ? -IndentationConstants.leadingViewVerticalPadding : 0
            )
        }
    }

    private func addBackgroundColorView(color: UIColor?, width: CGFloat?) {
        let coloredView = coloredView(color: color)
        width.map {
            coloredView.widthAnchor.constraint(equalToConstant: $0).isActive = true
        }

        backgroundColorsStackView.addArrangedSubview(coloredView)
    }

    private func coloredView(color: UIColor?) -> UIView {
        let view = UIView()
        view.backgroundColor = color

        return view
    }

    private lazy var bottomColoredView = UIView()
    private var bottomColoredViewHeightConstraint: NSLayoutConstraint?

    // MARK: - Subviews setup

    private func setupSubviews() {
        addSubview(wrapperView) {
            $0.pinToSuperview(excluding: [.bottom])
            $0.bottom.equal(to: bottomAnchor, priority: .init(rawValue: 997))
        }

        leadingView.isHidden = true
        contentStackView.addSubview(leadingView) {
            $0.pinToSuperview(excluding: [.right, .bottom], insets: .init(top: IndentationConstants.leadingViewVerticalPadding, left: 0, bottom: 0, right: 0))
            leadingViewWidthConstraint = $0.width.equal(to: 0)
            leadingViewBottomConstraint = $0.bottom.equal(to: contentStackView.bottomAnchor)
            leadingViewBottomConstraint?.isActive = true
        }

        var blockViewToContentbottomConstraint: NSLayoutConstraint?
        contentStackView.addSubview(blockView) {
            $0.pinToSuperview(excluding: [.left, .bottom], insets: .zero)
            $0.leading.equal(to: leadingView.trailingAnchor)
            blockViewToContentbottomConstraint = $0.bottom.equal(to: contentStackView.bottomAnchor)
        }

        wrapperView.addSubview(bottomColoredView) {
            $0.pinToSuperview(excluding: [.top])
            bottomColoredViewHeightConstraint = $0.height.equal(to: 0)
        }

        wrapperView.addSubview(contentStackView) {
            let leadingConstraint = $0.leading.equal(to: wrapperView.leadingAnchor)
            let trailingConstraint = $0.trailing.equal(to: wrapperView.trailingAnchor)
            let topConstraint = $0.top.equal(to: wrapperView.topAnchor)
            $0.bottom.equal(to: bottomColoredView.topAnchor)

            if let bottomConstraint = blockViewToContentbottomConstraint {
                contentConstraints = .init(
                    leadingConstraint: leadingConstraint,
                    trailingConstraint: trailingConstraint,
                    topConstraint: topConstraint,
                    bottomConstraint: bottomConstraint
                )
            }
        }

        addSubview(backgroundColorsStackView) {
            $0.pinToSuperview(excluding: [.bottom])
            $0.bottom.equal(to: contentStackView.bottomAnchor)
        }

        addSubview(selectionView) {
            $0.pin(to: contentStackView, excluding: [.bottom], insets: .init(top: 0, left: -8, bottom: 0, right: 8))
            $0.bottom.equal(to: blockView.bottomAnchor, constant: 0)
        }

        bringSubviewToFront(wrapperView)
        bringSubviewToFront(selectionView)
    }

    // MARK: - UIDragInteractionDelegate

    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        guard let dragConfiguration = dragConfiguration else {
            return []
        }

        let provider = NSItemProvider(object: dragConfiguration.id as NSItemProviderWriting)
        let item = UIDragItem(itemProvider: provider)
        item.localObject = dragConfiguration

        contentStackView.backgroundColor = indentationSettings?.relativeBackgroundColor
        let dragPreview = UIDragPreview(view: contentStackView)

        item.previewProvider = { dragPreview }

        return [item]
    }

    func dragInteraction(_ interaction: UIDragInteraction, session: UIDragSession, didEndWith operation: UIDropOperation) {
        contentStackView.backgroundColor = .clear
    }
}

private enum IndentationConstants {
    static let indentationWidth: CGFloat = 24
    static let leadingViewVerticalPadding: CGFloat = 6
}

private extension IndentationSettings {
    var relativeBackgroundColor: UIColor {
        if let backgroundColor = backgroundColor { return backgroundColor }

        let last = parentBlocksInfo.last { settings in
            settings.color != nil
        }

        return last?.color ?? .clear
    }
}
