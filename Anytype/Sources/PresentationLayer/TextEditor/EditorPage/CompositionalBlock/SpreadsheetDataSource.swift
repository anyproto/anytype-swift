import AnytypeCore
import UIKit
import Services


final class SpreadsheetViewDataSource {
    typealias DataSource = UICollectionViewDiffableDataSource<Int, EditorItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, EditorItem>

    var allModels = [[EditorItem]]()
    private lazy var dataSource: DataSource = makeCollectionViewDataSource()
    private let collectionView: EditorCollectionView
    private let templateCell = EditorViewListCell()
    
    init(collectionView: EditorCollectionView) {
        self.collectionView = collectionView
    }

    func templateCell(at indexPath: IndexPath) -> UICollectionViewCell {
        let item = allModels[indexPath.section][indexPath.row]
        setupCell(cell: templateCell, indexPath: indexPath, item: item.contentConfigurationProvider, template: true)
        return templateCell
    }

    func contentConfigurationProvider(
        at indexPath: IndexPath
    ) -> (any ContentConfigurationProvider)? {
        let item = allModels[indexPath.section][indexPath.row]

        return item.contentConfigurationProvider
    }

    func reconfigureItems(items: [EditorItem]) {
        let filtered = dataSource.snapshot().itemIdentifiers.filter { items.contains($0) }
        guard filtered.isNotEmpty else { return }
        
        var snapshot = dataSource.snapshot()
        snapshot.reconfigureItems(filtered)
        
    
        dataSource.apply(snapshot)
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
    }

    func reloadCell(for indexPath: IndexPath) {
        dataSource.itemIdentifier(for: indexPath)
            .map(reloadCell(for:))
    }

    func reloadCell(for item: EditorItem) {
        guard let indexPath = dataSource.indexPath(for: item),
              let cell = collectionView.cellForItem(at: indexPath) as? EditorViewListCell else { return }

        setupCell(cell: cell, indexPath: indexPath, item: item.contentConfigurationProvider, template: false)
    }

    func dataSourceItem(for blockId: String) -> EditorItem? {
        dataSource.snapshot().itemIdentifiers.first {
            switch $0 {
            case let .block(block):
                return block.info.id == blockId
            case .header, .system:
                return false
            }
        }
    }

    func indexPath(for blockId: String) -> IndexPath? {
        guard let item = dataSourceItem(for: blockId) else { return nil }

        return dataSource.indexPath(for: item)
    }

    func item(for indexPath: IndexPath) -> EditorItem? {
        dataSource.itemIdentifier(for: indexPath)
    }

    private func createCellRegistration() -> UICollectionView.CellRegistration<EditorViewListCell, any ContentConfigurationProvider> {
        .init { [weak self] cell, indexPath, item in
            self?.setupCell(cell: cell, indexPath: indexPath, item: item, template: false)
        }
    }

    func decorationRegistration() -> UICollectionView.SupplementaryRegistration<SelectionDecorationView> {
        .init(elementKind: SelectionDecorationView.reusableIdentifier) { supplementaryView, elementKind, indexPath in
            
        }
    }

    private func setupCell(
        cell: EditorViewListCell,
        indexPath: IndexPath,
        item: some ContentConfigurationProvider,
        template: Bool
    ) {
        cell.contentConfiguration = item.makeSpreadsheetConfiguration()
        cell.contentView.isUserInteractionEnabled = true

        cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
        if FeatureFlags.rainbowViews {
            cell.fillSubviewsWithRandomColors(recursively: false)
        }

        if !template, let dynamicHeightView = cell.contentView as? any DynamicHeightView {
            dynamicHeightView.heightDidChanged = { [weak self] in
                (self?.collectionView.collectionViewLayout as? SpreadsheetLayout)?.setNeedsLayout(indexPath: indexPath)
            }
        }
    }

    func makeCollectionViewDataSource() -> DataSource {
        let cellRegistration = createCellRegistration()
        let decorationRegistration = decorationRegistration()

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
                cell.isMoving = self.collectionView.indexPathsForMovingItems.contains(indexPath)
                cell.isLocked = self.collectionView.isLocked
            }


            return cell
        }

        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
            switch kind {
            case SelectionDecorationView.reusableIdentifier:
                return collectionView.dequeueConfiguredReusableSupplementary(using: decorationRegistration, for: indexPath)
            default:
                return nil
            }
        }

        return dataSource
    }

    func applyBlocksSectionSnapshot(
        _ snapshot: Snapshot,
        animatingDifferences: Bool
    ) {
        let selectedIndexPath = collectionView.indexPathsForSelectedItems

        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)

        selectedIndexPath?.forEach {
            self.collectionView.selectItem(at: $0, animated: false, scrollPosition: [])
        }
    }
}

extension EditorItem {
    var contentConfigurationProvider: any ContentConfigurationProvider {
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


private extension IndexPath {
    var topIndexPath: IndexPath {
        .init(row: row, section: section - 1)
    }

    var bottomIndexPath: IndexPath {
        .init(row: row, section: section + 1)
    }

    var leftIndexPath: IndexPath {
        .init(row: row - 1, section: section)
    }

    var rightIndexPath: IndexPath {
        .init(row: row + 1, section: section)
    }
}

struct SpreadsheetSelectionHelper {
    static func columnSelected(
        indexPaths: [IndexPath],
        sectionsCount: Int
    ) -> [[IndexPath]] {
        let selectedColumns = Set(indexPaths.map { $0.row })
        var allGroups = [[IndexPath]]()

        var currentGroup = [IndexPath]()

        for i in 0...(selectedColumns.max() ?? 0) {
            if selectedColumns.contains(i) {
                currentGroup.append(contentsOf: allIndexPaths(for: i, sectionsCount: sectionsCount))
            } else {
                continue
            }

            if !selectedColumns.contains(i + 1) {
                allGroups.append(currentGroup)
                currentGroup.removeAll()
            }
        }

        return allGroups
    }

    static func rowsSelected(
        indexPaths: [IndexPath],
        rowsCount: Int
    ) -> [[IndexPath]] {
        let selectedRows = Set(indexPaths.map { $0.section })
        var allGroups = [[IndexPath]]()

        var currentGroup = [IndexPath]()

        for i in 0...(selectedRows.max() ?? 0) {
            if selectedRows.contains(i) {
                currentGroup.append(contentsOf: allIndexPaths(for: i, rowsCount: rowsCount))
            } else {
                continue
            }

            if !selectedRows.contains(i + 1) {
                allGroups.append(currentGroup)
                currentGroup.removeAll()
            }
        }

        return allGroups
    }

    static func allIndexPaths(for rowIndex: Int, sectionsCount: Int) -> [IndexPath] {
        (0...sectionsCount - 1).map {
            IndexPath(row: rowIndex, section: $0)
        }
    }

    static func allIndexPaths(for sectionIndex: Int, rowsCount: Int) -> [IndexPath] {
        (0...rowsCount - 1).map {
            IndexPath(row: $0, section: sectionIndex)
        }
    }

    static func groupSelected(indexPaths: [IndexPath]) -> [[IndexPath]] {
        let selectedIndexPaths = Set(indexPaths)
        var alreadyUsedIndexPaths = Set<IndexPath>()
        var allNearbyIndexPaths = [[IndexPath]]()

        for indexPath in indexPaths {
            guard !alreadyUsedIndexPaths.contains(indexPath) else { continue }

            let nearbyIndexPaths = nearbyIndexPaths(
                indexPath: indexPath,
                selectedIndexPaths: selectedIndexPaths,
                alreadyUsedIndexPaths: &alreadyUsedIndexPaths
            )

            allNearbyIndexPaths.append(nearbyIndexPaths)
        }

        return allNearbyIndexPaths
    }

    private static func nearbyIndexPaths(
        indexPath: IndexPath,
        selectedIndexPaths: Set<IndexPath>,
        alreadyUsedIndexPaths: inout Set<IndexPath>
    ) -> [IndexPath] {
        alreadyUsedIndexPaths.insert(indexPath)

        let adjacentIndexPaths: Set<IndexPath> = [
            indexPath.topIndexPath,
            indexPath.leftIndexPath,
            indexPath.rightIndexPath,
            indexPath.bottomIndexPath
        ]

        let intersections = selectedIndexPaths
            .intersection(adjacentIndexPaths)
            .subtracting(alreadyUsedIndexPaths)

        var indexPaths = [IndexPath]()
        intersections.forEach { intersectionIndexPath in
            alreadyUsedIndexPaths.insert(intersectionIndexPath)

            indexPaths.append(intersectionIndexPath)

            let nearbyIndexPaths = nearbyIndexPaths(
                indexPath: intersectionIndexPath,
                selectedIndexPaths: selectedIndexPaths,
                alreadyUsedIndexPaths: &alreadyUsedIndexPaths
            )

            indexPaths.append(contentsOf: nearbyIndexPaths)
        }

        indexPaths.append(indexPath)

        return indexPaths
    }

}
