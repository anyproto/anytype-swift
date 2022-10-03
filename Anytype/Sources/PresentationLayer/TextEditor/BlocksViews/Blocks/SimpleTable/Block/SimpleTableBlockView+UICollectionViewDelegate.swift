import UIKit

extension SimpleTableBlockView: UICollectionViewDelegate {

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
    }

    func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> Bool {
        return collectionView.isEditing
    }
}
