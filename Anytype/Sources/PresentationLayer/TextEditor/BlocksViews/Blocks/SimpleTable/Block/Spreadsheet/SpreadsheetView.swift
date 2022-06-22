import UIKit
import UIKit

final class SpreadsheetView<View: BlockContentView>: UIView & UIContentView, UIDragInteractionDelegate {
    typealias Configuration = SpreadsheetBlockConfiguration<View.Configuration>

    var configuration: UIContentConfiguration {
        get {
            Configuration(
                blockConfiguration: blockConfiguration,
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

            dragConfiguration = newConfiguration.dragConfiguration
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
    private lazy var selectionView = BaseSelectionView()
    private lazy var viewDragInteraction = UIDragInteraction(delegate: self)

    init(configuration: Configuration) {
        self.blockConfiguration = configuration.blockConfiguration
        self.currentConfigurationState = configuration.currentConfigurationState
        self.dragConfiguration = configuration.dragConfiguration

        super.init(frame: .zero)

        setupSubviews()

        blockView.update(with: configuration.blockConfiguration)
        configuration.currentConfigurationState.map { blockView.update(with: $0) }

        setupDragInteraction()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        addSubview(blockView) {
            $0.pinToSuperview(excluding: [.bottom], insets: blockConfiguration.contentInsets)
            $0.bottom.equal(
                to: bottomAnchor,
                constant: blockConfiguration.contentInsets.bottom,
                priority: .init(999)
            )
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
