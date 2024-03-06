import UIKit
import Services
import Combine

final class SimpleTableBlockView: UIView, BlockContentView {
    lazy var dataSource = SpreadsheetViewDataSource(collectionView: dynamicLayoutView.collectionView)
    lazy var spreadsheetLayout = SpreadsheetLayout()
    var viewModel: SimpleTableViewModel?

    private lazy var dynamicLayoutView = DynamicCollectionLayoutView(frame: .zero)
    private var collectionView: EditorCollectionView { dynamicLayoutView.collectionView }
    private var modelsSubscriptions = [AnyCancellable]()

    private var cancellables = [AnyCancellable]()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupSubview()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupSubview()
    }

    func update(with configuration: SimpleTableBlockContentConfiguration) {
        viewModel = nil
        spreadsheetLayout.invalidateEverything()
        modelsSubscriptions.removeAll()
        dataSource.allModels = []

        let dependencies = configuration.dependenciesBuilder.buildDependenciesContainer(blockInformation: configuration.info)

        self.spreadsheetLayout.dataSource = dataSource
        self.viewModel = dependencies.viewModel

        collectionView.delegate = self

        dynamicLayoutView.update(
            with: .init(
                layoutHeightMemory: .hashable(configuration.info.id as AnyHashable),
                layout: spreadsheetLayout,
                heightDidChanged: { configuration.onChangeHeight() }
            )
        )

        viewModel?.$widths.sink { [weak spreadsheetLayout] width in
            spreadsheetLayout?.itemWidths = width
        }.store(in: &modelsSubscriptions)

        viewModel?.dataSource = dataSource

        setupHandlers()
    }

    private func setupHandlers() {
        viewModel?.stateManager.editorEditingStatePublisher.sink { [weak self] state in
            guard let self else { return }
            switch state {
            case .selecting:
                UIApplication.shared.hideKeyboard()
                collectionView.isEditing = false
                collectionView.isLocked = false
                spreadsheetLayout.reselectSelectedCells()
            case .editing:
                collectionView.isEditing = true
                collectionView.isLocked = false
            case .moving, .loading:
                return
            case .readonly, .simpleTablesSelection:
                collectionView.isLocked = true
            }
        }.store(in: &cancellables)

        viewModel?.stateManager.selectedBlocksIndexPathsPublisher.sink { [weak self] indexPaths in
            guard let self else { return }
            collectionView.deselectAllSelectedItems()

            indexPaths.forEach {
                self.collectionView.selectItem(at: $0, animated: false, scrollPosition: [])
            }
            spreadsheetLayout.reselectSelectedCells()

        }.store(in: &cancellables)

        viewModel?.stateManager.selectedMenuTabPublisher.sink { [weak self] _ in
            self?.spreadsheetLayout.reselectSelectedCells()
        }.store(in: &cancellables)
    }

    private func setupSubview() {
        addSubview(dynamicLayoutView) {
            $0.pinToSuperview(insets: .init(top: 10, left: 0, bottom: 0, right: 0))
        }

        dynamicLayoutView.collectionView.contentInset = .init(
            top: 0,
            left: 20,
            bottom: 0,
            right: 20
        )
    }
}
