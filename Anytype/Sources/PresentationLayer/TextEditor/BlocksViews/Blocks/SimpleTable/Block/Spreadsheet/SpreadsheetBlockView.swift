import UIKit

private enum Constants {
    static let edges = UIEdgeInsets(top: 9, left: 12, bottom: -9, right: -12)
}

final class SpreadsheetBlockView<View: BlockContentView>: UIView & UIContentView, UIDragInteractionDelegate, DynamicHeightView {
    typealias Configuration = SpreadsheetBlockConfiguration<View.Configuration>

    var heightDidChanged: (() -> Void)?

    var configuration: UIContentConfiguration {
        get {
            Configuration(
                blockConfiguration: blockConfiguration,
                styleConfiguration: styleConfiguration,
                currentConfigurationState: currentConfigurationState,
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

            if newConfiguration.styleConfiguration != styleConfiguration {
                styleConfiguration = newConfiguration.styleConfiguration
            }

            dragConfiguration = newConfiguration.dragConfiguration
        }
    }

    private var styleConfiguration: SpreadsheetStyleConfiguration {
        didSet {
            updateStyleConfiguration(configuration: styleConfiguration)
        }
    }

    private var blockConfiguration: View.Configuration {
        didSet {
            blockView.update(with: blockConfiguration)
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

    private lazy var blockView = View(frame: .zero)
    private lazy var selectionView = SpreadsheetSelectionView()
    private lazy var viewDragInteraction = UIDragInteraction(delegate: self)

    init(configuration: Configuration) {
        self.blockConfiguration = configuration.blockConfiguration
        self.currentConfigurationState = configuration.currentConfigurationState
        self.dragConfiguration = configuration.dragConfiguration
        self.styleConfiguration = configuration.styleConfiguration

        super.init(frame: .zero)

        setupSubviews()

        blockView.update(with: configuration.blockConfiguration)
        configuration.currentConfigurationState.map { blockView.update(with: $0) }

        setupDragInteraction()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateStyleConfiguration(configuration: SpreadsheetStyleConfiguration) {
        backgroundColor = configuration.backgroundColor
    }

    // MARK: - UICollectionView configuration

    private func update(with state: UICellConfigurationState) {
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
        addInteraction(viewDragInteraction)
    }


    // MARK: - Subviews setup

    private func setupSubviews() {
        setupLayout()

        layer.borderWidth = 0.5
        layer.borderColor = UIColor.strokePrimary.cgColor

        if let dynamicHeightBlockView = blockView as? DynamicHeightView {
            dynamicHeightBlockView.heightDidChanged = { [weak self] in
                self?.heightDidChanged?()
            }
        }

        if let firstReponderChangeHandler = blockView as? FirstResponder {
            firstReponderChangeHandler.isFirstResponderValueChangeHandler = { [weak self] isFirstResponder in
                guard !(self?.currentConfigurationState?.isSelected ?? false) else { return }
                
                self?.selectionView.updateStyle(isSelected: isFirstResponder)
            }
        }
    }

    private func setupLayout() {
        addSubview(blockView) {
            $0.pinToSuperview(excluding: [.bottom], insets: Constants.edges)
            $0.bottom.equal(
                to: bottomAnchor,
                constant: Constants.edges.bottom,
                priority: .init(999)
            )
        }

        addSubview(selectionView) {
            $0.pinToSuperview()
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

        let dragPreview = UIDragPreview(view: self)

        item.previewProvider = { dragPreview }

        return [item]
    }
}
