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

    /// All backgrounds are here. Added through horizontal `StackView` and width (block + indentation) constraint.
    private lazy var backgroundColorsStackView = UIStackView()
    private lazy var wrapperView = UIView()

    /// Horizontal stack view like view.
    private lazy var contentStackView = UIView()
    private lazy var leadingView = TextBlockIconView(viewType: .quote)
    private lazy var blockView = View(frame: .zero)
    private lazy var selectionView = BaseSelectionView()
    private lazy var indentationViews = [UIView]()

    private var leadingWidthConstraint: NSLayoutConstraint?
    private var contentConstraints: InsetConstraints?

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

        if state.isMoving {
            backgroundColor = UIColor.Background.blue
        } else {
            backgroundColor = .clear
        }
    }

    // MARK: - Drag&Drop

    private func setupDragInteraction() {
        guard dragConfiguration != nil, viewDragInteraction.view == nil else { return }
        contentStackView.addInteraction(viewDragInteraction)
    }

    // MARK: - Indentation

    private func updateIndentationPaddings() {
        var blockContentInsets = blockConfiguration.contentInsets
        let indentationLevel = indentationSettings?.parentBlocksInfo.count ?? 0
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

        configureParentIndentationStyles(
            parentIndentationStyles: indentationSettings.parentBlocksInfo.map(\.indentationStyle)
        )

        configureBackgroundColors(
            parentBackgrounds: indentationSettings.parentBlocksInfo.map(\.color),
            backgroundColor: indentationSettings.backgroundColor
        )
    }

    private func configureLeadingView(with style: BlockIndentationStyle) {
        switch style {
        case .highlighted:
            leadingWidthConstraint?.constant = IndentationConstants.indentationWidth
            leadingView.isHidden = false
        default:
            leadingWidthConstraint?.constant = 0
            leadingView.isHidden = true
        }
    }

    private func configureParentIndentationStyles(parentIndentationStyles: [BlockIndentationStyle]) {
        var leadingContraintValue = blockConfiguration.contentInsets.left

        parentIndentationStyles.forEach() { element in
            if case .highlighted = element {
                addBlockLeadingView(with: leadingContraintValue)
            }

            leadingContraintValue = leadingContraintValue + IndentationConstants.indentationWidth
        }
    }

    private func addBlockLeadingView(with indentation: CGFloat) {
        let leadingView = TextBlockLeadingView()
        leadingView.update(style: .quote)

        indentationViews.append(leadingView)
        addSubview(leadingView) {
            $0.pinToSuperview(
                excluding: [.right],
                insets: .init(top: 0, left: indentation, bottom: 0, right: 0)
            )
        }
    }

    private func configureBackgroundColors(
        parentBackgrounds: [UIColor?],
        backgroundColor: UIColor?
    ) {
        parentBackgrounds.enumerated().forEach { element in
            let coloredView = coloredView(color: element.element)

            if element.offset == 0 {
                let firstColorWidth = blockConfiguration.contentInsets.left + IndentationConstants.indentationWidth
                coloredView.widthAnchor.constraint(equalToConstant: firstColorWidth).isActive = true
            } else {
                coloredView.widthAnchor.constraint(equalToConstant: IndentationConstants.indentationWidth).isActive = true
            }

            backgroundColorsStackView.addArrangedSubview(coloredView)
        }

        let view = coloredView(color: backgroundColor ?? parentBackgrounds.last.flatMap { $0 })
        backgroundColorsStackView.addArrangedSubview(view)
    }


    private func coloredView(color: UIColor?) -> UIView {
        let view = UIView()
        view.backgroundColor = color

        return view
    }


    // MARK: - Subviews setup

    private func setupSubviews() {
        addSubview(wrapperView) {
            $0.pinToSuperview()
        }

        leadingView.isHidden = true
        contentStackView.addSubview(leadingView) {
            $0.pinToSuperview(excluding: [.right], insets: .zero)
            leadingWidthConstraint = $0.width.equal(to: 0)
        }

        var blockViewToContentbottomConstraint: NSLayoutConstraint?
        contentStackView.addSubview(blockView) {
            $0.pinToSuperview(excluding: [.left, .bottom], insets: .zero)
            $0.leading.equal(to: leadingView.trailingAnchor)
            blockViewToContentbottomConstraint = $0.bottom.equal(to: contentStackView.bottomAnchor)
        }

        wrapperView.addSubview(contentStackView) {
            let leadingConstraint = $0.leading.equal(to: wrapperView.leadingAnchor)
            let trailingConstraint = $0.trailing.equal(to: wrapperView.trailingAnchor)
            let topConstraint = $0.top.equal(to: wrapperView.topAnchor)
            $0.bottom.equal(to: wrapperView.bottomAnchor)

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
            $0.pin(to: contentStackView, insets: .init(top: 1, left: -8, bottom: -1, right: 8))
        }

        bringSubviewToFront(wrapperView)
    }

    // MARK: - UIDragInteractionDelegate

    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        guard let dragConfiguration = dragConfiguration else {
            return []
        }

        let provider = NSItemProvider(object: dragConfiguration.id as NSItemProviderWriting)
        let item = UIDragItem(itemProvider: provider)
        item.localObject = dragConfiguration

        return [item]
    }
}

private enum IndentationConstants {
    static let indentationWidth: CGFloat = 24
}
