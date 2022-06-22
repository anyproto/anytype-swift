import AnytypeCore
import UIKit

final class SpreadsheetViewDataSource {
    typealias DataSource = UICollectionViewDiffableDataSource<Int, EditorItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, EditorItem>

    private lazy var dataSource: DataSource = makeCollectionViewDataSource()
    private let collectionView: EditorCollectionView

    init(collectionView: EditorCollectionView) {
        self.collectionView = collectionView
    }

    func dequeueCell(at indexPath: IndexPath) -> UICollectionViewCell {
        return dataSource.collectionView(collectionView, cellForItemAt: indexPath)
    }

    func item(at indexPath: IndexPath) -> EditorItem? {
        return dataSource.itemIdentifier(for: indexPath)
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
        applyBlocksSectionSnapshot(snapshot, animatingDifferences: true)
    }

    func reloadCell(for item: EditorItem) {
        guard let indexPath = dataSource.indexPath(for: item),
              let cell = collectionView.cellForItem(at: indexPath) as? UICollectionViewListCell else { return }

        switch item {
        case .header: break
        case .block(let blockViewModel):
            cell.contentConfiguration = blockViewModel.makeContentConfiguration(maxWidth: cell.bounds.width)
        case .system(let systemContentConfiguationProvider):
            cell.contentConfiguration = systemContentConfiguationProvider.makeContentConfiguration(maxWidth: cell.bounds.width)
        }
    }


    private func createCellRegistration() -> UICollectionView.CellRegistration<EditorViewListCell, ContentConfigurationProvider> {
        .init { [weak self] cell, indexPath, item in
            self?.setupCell(cell: cell, indexPath: indexPath, item: item)
        }
    }

    private func createSystemCellRegistration() -> UICollectionView.CellRegistration<EditorViewListCell, SystemContentConfiguationProvider> {
        .init { (cell, indexPath, item) in
            cell.contentConfiguration = item.makeContentConfiguration(maxWidth: cell.bounds.width)
        }
    }

    private func setupCell(
        cell: UICollectionViewListCell,
        indexPath: IndexPath,
        item: ContentConfigurationProvider
    ) {
        cell.contentConfiguration = item.makeContentConfiguration(maxWidth: cell.bounds.width)
        cell.contentView.isUserInteractionEnabled = true

        cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
        if FeatureFlags.rainbowViews {
            cell.fillSubviewsWithRandomColors(recursively: false)
        }
    }

    func makeCollectionViewDataSource() -> DataSource {
        let cellRegistration = createCellRegistration()
        let systemCellRegistration = createSystemCellRegistration()

        let dataSource = DataSource(
            collectionView: collectionView
        ) { [weak self] (collectionView, indexPath, dataSourceItem) -> UICollectionViewCell? in
            let cell: UICollectionViewCell
            switch dataSourceItem {
            case let .block(block):
                cell = collectionView.dequeueConfiguredReusableCell(
                    using: cellRegistration,
                    for: indexPath,
                    item: block
                )
            case .header:
                anytypeAssertionFailure("Not supported", domain: .simpleTables)
                return nil
            case let .system(configuration):
                return collectionView.dequeueConfiguredReusableCell(
                    using: systemCellRegistration,
                    for: indexPath,
                    item: configuration
                )
            }

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
            dataSource.apply(snapshot, animatingDifferences: true)
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
