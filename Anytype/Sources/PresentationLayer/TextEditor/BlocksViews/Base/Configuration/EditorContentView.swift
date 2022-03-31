import UIKit

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
        }
    }

    private var blockConfiguration: View.Configuration {
        didSet {
            view.update(with: blockConfiguration)
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
                view.update(with: $0)
            }
        }
    }

    private lazy var backgroundColorsStackView = UIStackView()  
    private let view = View(frame: .zero)
    private lazy var selectionView = BaseSelectionView()
    private var viewLeadingConstraint: NSLayoutConstraint?
    private lazy var viewDragInteraction = UIDragInteraction(delegate: self)

    init(configuration: Configuration) {
        self.blockConfiguration = configuration.blockConfiguration
        self.currentConfigurationState = configuration.currentConfigurationState
        self.indentationSettings = configuration.indentationSettings
        self.dragConfiguration = configuration.dragConfiguration

        super.init(frame: .zero)

        setupSubviews()

        view.update(with: configuration.blockConfiguration)
        configuration.currentConfigurationState.map { view.update(with: $0) }

        indentationSettings.map(update(with:))

        setupDragInteraction()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func update(with state: UICellConfigurationState) {
        selectionView.updateStyle(isSelected: state.isSelected)

        isUserInteractionEnabled = state.isEditing

        if state.isMoving {
            backgroundColor = UIColor.Background.blue
        } else {
            backgroundColor = .clear
        }
    }

    private func setupDragInteraction() {
        guard dragConfiguration != nil, viewDragInteraction.view == nil else { return }
        view.addInteraction(viewDragInteraction)
    }

    private func update(with indentationSettings: IndentationSettings) {
        backgroundColorsStackView.axis = .horizontal
        backgroundColorsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        var leadingContraintValue: CGFloat = 0.0

        for (i, color) in indentationSettings.parentColors.enumerated() {
            let view = coloredView(color: color)

            if i != indentationSettings.parentColors.count - 1 {
                view.widthAnchor.constraint(equalToConstant: IndentationConstants.indentationWidth).isActive = true
            }

            leadingContraintValue = leadingContraintValue + IndentationConstants.indentationWidth

            backgroundColorsStackView.addArrangedSubview(view)
        }

        viewLeadingConstraint?.constant = leadingContraintValue
    }

    private func coloredView(color: UIColor?) -> UIView {
        let view = UIView()
        view.backgroundColor = color

        return view
    }


    private func setupSubviews() {
        addSubview(backgroundColorsStackView) {
            $0.pinToSuperview()
        }

        addSubview(view) {
            $0.pinToSuperview(excluding: [.left])
            viewLeadingConstraint = $0.leading.equal(to: leadingAnchor, constant: 0)
        }

        addSubview(selectionView) {
            $0.pin(to: view, insets: UIEdgeInsets(top: 0, left: 8, bottom: -2, right: -8))
        }
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
