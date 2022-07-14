import UIKit
import BlocksModels
import Combine

final class SimpleTableBlockView: UIView, BlockContentView {
    private lazy var dynamicLayoutView = DynamicCollectionLayoutView(frame: .zero)
    private lazy var spreadsheetLayout = SpreadsheetLayout(dataSource: dataSource)
    private lazy var dataSource = SpreadsheetViewDataSource(
        collectionView: dynamicLayoutView.collectionView
    )

    private var viewModel: SimpleTableViewModel?
    private var modelsSubscriptions = [AnyCancellable]()
    private weak var blockDelegate: BlockDelegate?

    private var cancellables = [AnyCancellable]()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupSubview()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupSubview()
    }

    func prepareForReuse() {
        modelsSubscriptions.removeAll()
    }

    func update(with configuration: SimpleTableBlockContentConfiguration) {
        let dependencies = configuration.dependenciesBuilder.buildDependenciesContainer(blockInformation: configuration.info)

        self.blockDelegate = dependencies.blockDelegate
        self.viewModel = dependencies.viewModel

        collectionView.delegate = self
        dynamicLayoutView.update(
            with: .init(
                layoutHeightMemory: .none,
                layout: spreadsheetLayout,
                heightDidChanged: { [weak self] in self?.blockDelegate?.textBlockSetNeedsLayout() }
            )
        )

        modelsSubscriptions.removeAll()
        viewModel?.$widths.sink { [weak spreadsheetLayout] width in
            spreadsheetLayout?.itemWidths = width
        }.store(in: &modelsSubscriptions)

        spreadsheetLayout.relativePositionProvider = dependencies.relativePositionProvider

        viewModel?.dataSource = dataSource
        dependencies.stateManager.dataSource = dataSource

        setupHandlers()
    }

    override func endEditing(_ force: Bool) -> Bool {
        super.endEditing(force)
    }

    private func setupHandlers() {
        viewModel?.stateManager.editorEditingStatePublisher.sink { [unowned self] state in
            switch state {
            case .selecting:
                UIApplication.shared.hideKeyboard()
                dynamicLayoutView.collectionView.isEditing = false
                dynamicLayoutView.collectionView.isLocked = false
                spreadsheetLayout.reselectSelectedCells()
            case .editing:
                dynamicLayoutView.collectionView.isEditing = true
                dynamicLayoutView.collectionView.isLocked = false
            case .moving:
                fatalError()
            case .locked, .simpleTablesSelection:
                dynamicLayoutView.collectionView.isEditing = false
                dynamicLayoutView.collectionView.isLocked = true
            }

            var isEditing = false
            if case .editing = state {
                isEditing = true
            }


            collectionView.isEditing = isEditing
        }.store(in: &cancellables)

        viewModel?.stateManager.editorSelectedBlocks.sink { [unowned self] blockIds in
            blockIds.forEach(selectBlock)
            spreadsheetLayout.reselectSelectedCells()
        }.store(in: &cancellables)

        viewModel?.stateManager.selectedMenuTabPublisher.sink { [unowned self] _ in

            collectionView.deselectAllSelectedItems()

            let indexPathsForSelectedItemsNew = collectionView.indexPathsForSelectedItems ?? []
            viewModel?.stateManager.didUpdateSelectedIndexPaths(indexPathsForSelectedItemsNew)

            spreadsheetLayout.reselectSelectedCells()
        }.store(in: &cancellables)
    }

    private func selectBlock(blockId: BlockId) {
        guard let indexPath = dataSource.indexPath(for: blockId) else {
            return
        }

        dynamicLayoutView.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])

        let indexPathsForSelectedItems = collectionView.indexPathsForSelectedItems ?? []
        viewModel?.stateManager.didUpdateSelectedIndexPaths(indexPathsForSelectedItems)
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


// MARK: - UICollectionViewDelegate

extension SimpleTableBlockView: UICollectionViewDelegate {

    var collectionView: EditorCollectionView { dynamicLayoutView.collectionView }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        if collectionView.isEditing {
            let item = dataSource.item(for: indexPath)
            item?.didSelect(in: viewModel?.stateManager.editingState ?? .editing)

            collectionView.deselectItem(at: indexPath, animated: false)
        } else {
            guard let selectedMenuTab = viewModel?.stateManager.selectedMenuTab else { return }

            let indexPathsForSelectedItems = collectionView.indexPathsForSelectedItems ?? []
            switch selectedMenuTab {
            case .cell:
                break
            case .row:
                if let ip = indexPathsForSelectedItems.first(where: { $0.section == indexPath.section}) {
                    // deselect all

                    let allRowIndexPaths = SpreadsheetSelectionHelper.allIndexPaths(
                        for: ip.section,
                        rowsCount: collectionView.numberOfItems(inSection: 0)
                    )

                    allRowIndexPaths.forEach {
                        collectionView.selectItem(at: $0, animated: false, scrollPosition: [])
                    }
                }
            case .column:
                if let ip = indexPathsForSelectedItems.first(where: { $0.row == indexPath.row}) {
                    // deselect all

                    let allColumnIndexPaths = SpreadsheetSelectionHelper.allIndexPaths(
                        for: ip.row,
                        sectionsCount: collectionView.numberOfSections
                    )

                    allColumnIndexPaths.forEach {
                        collectionView.selectItem(at: $0, animated: false, scrollPosition: [])
                    }
                }
            }

            let indexPathsForSelectedItemsNew = collectionView.indexPathsForSelectedItems ?? []

            viewModel?.stateManager.didUpdateSelectedIndexPaths(indexPathsForSelectedItemsNew)
            spreadsheetLayout.reselectSelectedCells()
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didDeselectItemAt indexPath: IndexPath
    ) {
        guard let selectedMenuTab = viewModel?.stateManager.selectedMenuTab else { return }

        let indexPathsForSelectedItems = collectionView.indexPathsForSelectedItems ?? []
        switch selectedMenuTab {
        case .cell:
            break
        case .row:
            if let ip = indexPathsForSelectedItems.first(where: { $0.section == indexPath.section}) {
                // deselect all

                let allRowIndexPaths = SpreadsheetSelectionHelper.allIndexPaths(
                    for: ip.section,
                    rowsCount: collectionView.numberOfItems(inSection: 0)
                )

                allRowIndexPaths.forEach {
                    collectionView.deselectItem(at: $0, animated: false)
                }
            }
        case .column:
            if let ip = indexPathsForSelectedItems.first(where: { $0.row == indexPath.row}) {
                // deselect all

                let allColumnIndexPaths = SpreadsheetSelectionHelper.allIndexPaths(
                    for: ip.row,
                    sectionsCount: collectionView.numberOfSections
                )

                allColumnIndexPaths.forEach {
                    collectionView.deselectItem(at: $0, animated: false)
                }
            }
        }

        if let indexPathsForSelectedItems = collectionView.indexPathsForSelectedItems {
            viewModel?.stateManager.didUpdateSelectedIndexPaths(indexPathsForSelectedItems)
        }

        spreadsheetLayout.reselectSelectedCells()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        shouldHighlightItemAt indexPath: IndexPath
    ) -> Bool {
        return true
    }

    func collectionView(
        _ collectionView: UICollectionView,
        shouldSelectItemAt indexPath: IndexPath
    ) -> Bool {
        return true
//        guard let item = dataSource.item(for: indexPath) else { return false }
//
//        switch item {
//        case let .block(block):
//            if case .text = block.content, collectionView.isEditing { return false }
//
//            return viewModel?.stateManager.canSelectBlock(at: indexPath) ?? false
//        case .header, .system:
//            return true
//        }
    }

    func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> Bool {
        return collectionView.isEditing
    }
}
