import AnytypeCore
import UIKit

final class SpreadsheetViewDataSource {
    typealias DataSource = UICollectionViewDiffableDataSource<Int, EditorItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, EditorItem>

    var allModels = [[EditorItem]]()
    private lazy var dataSource: DataSource = makeCollectionViewDataSource()
    private let collectionView: EditorCollectionView

    init(collectionView: EditorCollectionView) {
        self.collectionView = collectionView
    }

    func dequeueCell(at indexPath: IndexPath) -> UICollectionViewCell {
        let item = allModels[indexPath.section][indexPath.row]

        return collectionView.dequeueConfiguredReusableCell(
            using: createCellRegistration(),
            for: indexPath,
            item: item.contentConfigurationProvider
        )
    }

    func contentConfigurationProvider(at indexPath: IndexPath) -> ContentConfigurationProvider? {
        let item = allModels[indexPath.section][indexPath.row]

        return item.contentConfigurationProvider
    }

    func reconfigureItems(items: [EditorItem]) {
        items.forEach(reloadCell(for:))
    }

    func update(
        changes: [EditorItem],
        allModels: [[EditorItem]]
    ) {
       reconfigureItems(items: changes)

        var snapshot = Snapshot()
        snapshot.appendSections(Array(0..<allModels.count))

        allModels.enumerated().forEach { index, sectionModels in
            snapshot.appendItems(sectionModels, toSection: index)
        }

        self.allModels = allModels
        applyBlocksSectionSnapshot(snapshot, animatingDifferences: true)

        collectionView.collectionViewLayout.prepare()
    }

    func reloadCell(for indexPath: IndexPath) {
        dataSource.itemIdentifier(for: indexPath)
            .map(reloadCell(for:))
    }

    func reloadCell(for item: EditorItem) {
        guard let indexPath = dataSource.indexPath(for: item),
              let cell = collectionView.cellForItem(at: indexPath) as? EditorViewListCell else { return }

        setupCell(cell: cell, indexPath: indexPath, item: item.contentConfigurationProvider)
    }


    private func createCellRegistration() -> UICollectionView.CellRegistration<EditorViewListCell, ContentConfigurationProvider> {
        .init { [weak self] cell, indexPath, item in
            self?.setupCell(cell: cell, indexPath: indexPath, item: item)
        }
    }

    private func setupCell(
        cell: EditorViewListCell,
        indexPath: IndexPath,
        item: ContentConfigurationProvider
    ) {
        cell.contentConfiguration = item.makeSpreadsheetConfiguration()
        cell.contentView.isUserInteractionEnabled = true

        cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
        if FeatureFlags.rainbowViews {
            cell.fillSubviewsWithRandomColors(recursively: false)
        }

        if let dynamicHeightView = cell.contentView as? DynamicHeightView {
            dynamicHeightView.heightDidChanged = { [weak self] in
                (self?.collectionView.collectionViewLayout as? SpreadsheetLayout)?.setNeedsLayout(indexPath: indexPath)
            }
        }
    }

    func makeCollectionViewDataSource() -> DataSource {
        let cellRegistration = createCellRegistration()

        let dataSource = DataSource(
            collectionView: collectionView
        ) { [weak self] (collectionView, indexPath, dataSourceItem) -> UICollectionViewCell? in
            let cell = collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: dataSourceItem.contentConfigurationProvider
            )

            // UIKit bug. isSelected works fine, UIConfigurationStateCustomKey properties sometimes switch to adjacent cellsAnytype/Sources/PresentationLayer/TextEditor/BlocksViews/Base/CustomStateKeys.swift
            if let self = self {
                (cell as? EditorViewListCell)?.isMoving = self.collectionView.indexPathsForMovingItems.contains(indexPath)
                (cell as? EditorViewListCell)?.isLocked = self.collectionView.isLocked
            }


            return cell
        }

        return dataSource
    }

    func applyBlocksSectionSnapshot(
        _ snapshot: Snapshot,
        animatingDifferences: Bool
    ) {
        if #available(iOS 15.0, *) {
            dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
        } else {
            UIView.performWithoutAnimation {
                dataSource.apply(snapshot, animatingDifferences: true)
            }
        }

        let selectedCells = collectionView.indexPathsForSelectedItems
        selectedCells?.forEach {
            self.collectionView.selectItem(at: $0, animated: false, scrollPosition: [])
        }
    }
}

private extension EditorItem {
    var contentConfigurationProvider: ContentConfigurationProvider {
        switch self {
        case .header(let viewModel):
            return viewModel
        case .block(let blockViewModel):
            return blockViewModel
        case .system(let systemContentConfiguationProvider):
            return systemContentConfiguationProvider
        }
    }
}
