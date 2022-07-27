import UIKit

final class SpreadsheetBlockView<View: BlockContentView>: UIView & UIContentView, DynamicHeightView {
    typealias Configuration = SpreadsheetBlockConfiguration<View.Configuration>

    var heightDidChanged: (() -> Void)?

    var configuration: UIContentConfiguration {
        get {
            Configuration(
                blockConfiguration: blockConfiguration,
                styleConfiguration: styleConfiguration,
                currentConfigurationState: currentConfigurationState,
                dragConfiguration: nil
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

    init(configuration: Configuration) {
        self.blockConfiguration = configuration.blockConfiguration
        self.currentConfigurationState = configuration.currentConfigurationState
        self.styleConfiguration = configuration.styleConfiguration

        super.init(frame: .zero)

        setupSubviews()

        blockView.update(with: configuration.blockConfiguration)
        configuration.currentConfigurationState.map { blockView.update(with: $0) }

        updateStyleConfiguration(configuration: styleConfiguration)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateStyleConfiguration(configuration: SpreadsheetStyleConfiguration) {
        backgroundColor = configuration.backgroundColor
    }

    // MARK: - UICollectionView configuration

    private func update(with state: UICellConfigurationState) {
        blockView.update(with: state)

        isUserInteractionEnabled = state.isEditing
        if state.isMoving {
            backgroundColor = UIColor.Background.blue
        } else {
            backgroundColor = styleConfiguration.backgroundColor
        }
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
            $0.pinToSuperview(excluding: [.bottom], insets: blockConfiguration.spreadsheetInsets)
            $0.bottom.equal(
                to: bottomAnchor,
                constant: blockConfiguration.spreadsheetInsets.bottom,
                priority: .init(999)
            )
        }

        addSubview(selectionView) {
            $0.pinToSuperview()
        }
    }
}
