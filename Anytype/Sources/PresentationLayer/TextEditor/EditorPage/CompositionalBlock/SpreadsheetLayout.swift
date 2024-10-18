import UIKit
import Combine
import AnytypeCore

final class SpreadsheetLayout: UICollectionViewLayout {
    weak var dataSource: SpreadsheetViewDataSource?
    var itemWidths = [CGFloat]() {
        didSet {
            reset()
        }
    }

    private var cachedSectionHeights = [Int: CGFloat]()
    private var attributes: [UICollectionViewLayoutAttributes] = []
    private var contentSize = CGSize.zero
    private lazy var selectionAttributes = SelectionDecorationAttributes(
        forSupplementaryViewOfKind: SelectionDecorationView.reusableIdentifier,
        with: IndexPath(row: 0, section: 0)
    )

    override var collectionViewContentSize: CGSize { contentSize }
    private var cancellables = [AnyCancellable]()

    private var lastSelectedAttributes = [UICollectionViewLayoutAttributes]()

    func invalidateEverything() {
        dataSource = nil
        cancellables.removeAll()
        attributes.removeAll()
        cachedSectionHeights.removeAll()
        contentSize = .zero
        lastSelectedAttributes.removeAll()
    }

    override func invalidateLayout() {
        super.invalidateLayout()
        attributes.removeAll()
    }

    override func layoutAttributesForElements(
        in rect: CGRect
    ) -> [UICollectionViewLayoutAttributes]? {
        guard dataSource?.allModels.count ?? 0 > 0 else {
            return nil
        }

        let attributes = (attributes + [selectionAttributes])

        return attributes
    }
    
    func reselectSelectedCells() {
        guard let collectionView = collectionView else { return }
        let selectedIndexPaths = collectionView.indexPathsForSelectedItems ?? []

        let selectedAttributes = attributes.filter { selectedIndexPaths.contains($0.indexPath) }
        let unionIndexPaths = SpreadsheetSelectionHelper.groupSelected(indexPaths: selectedIndexPaths)

        guard lastSelectedAttributes != selectedAttributes else {
            return
        }

        selectionAttributes.selectedRects = unionIndexPaths.map { indexPaths in // It could be slow. Need improvements.
            indexPaths.compactMap { indexPath in
                let attribute = attributes.first(where: { $0.indexPath == indexPath })

                return attribute?.frame ?? .zero
            }
        }

        lastSelectedAttributes = selectedAttributes
    }

    override func prepare() {
        guard let dataSource = dataSource else {
            return
        }

        for sectionIndex in 0..<dataSource.allModels.count {
            var sectionMaxHeight: CGFloat = 0

            for rowIndex in 0..<dataSource.allModels[sectionIndex].count {
                let indexPath = IndexPath(row: rowIndex, section: sectionIndex)

                guard let columnWidth = itemWidths[safe: rowIndex] else {
                    continue
                }

                let cell = dataSource.templateCell(at: indexPath)
                
                let maxSize = CGSize(
                    width: columnWidth,
                    height: .greatestFiniteMagnitude
                )
                let size = cell.systemLayoutSizeFitting(
                    maxSize,
                    withHorizontalFittingPriority: .required,
                    verticalFittingPriority: .fittingSizeLevel
                )

                sectionMaxHeight = size.height > sectionMaxHeight ? size.height : sectionMaxHeight
            }

            cachedSectionHeights[sectionIndex] = sectionMaxHeight
        }

        reloadAttributesCache()
    }

    private func reset() {
        prepare()
    }

    private func reloadAttributesCache() {
        attributes.removeAll()

        guard let dataSource = dataSource else {
            return
        }

        var fullHeight: CGFloat = 0
        var originY: CGFloat = 2
        for sectionIndex in 0..<dataSource.allModels.count {
            guard let maxSectionHeight = cachedSectionHeights[sectionIndex] else {
                        anytypeAssertionFailure("Reload attributes cache broken logic")
                        return
                    }

            var originX: CGFloat = 2
            fullHeight = fullHeight + maxSectionHeight

            for row in 0..<dataSource.allModels[sectionIndex].count {
                guard let rowWidth = itemWidths[safe: row] else { continue }
                let indexPath = IndexPath(row: row, section: sectionIndex)

                let rowLayoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                rowLayoutAttributes.frame = .init(
                    origin: .init(x: originX, y: originY),
                    size: .init(width: rowWidth, height: maxSectionHeight)
                )

                attributes.append(rowLayoutAttributes)

                originX = originX + rowWidth
            }

            originY = originY + maxSectionHeight
        }

        selectionAttributes.frame = .init(origin: .zero, size: contentSize)
        selectionAttributes.zIndex = 14

        reselectSelectedCells()

        contentSize = .init(width: itemWidths.reduce(0, +) + 4, height: fullHeight + 10 + 2)
    }
}

extension SpreadsheetLayout {
    func setNeedsLayout(indexPath: IndexPath) {
        guard let dataSource = dataSource,
              dataSource.contentConfigurationProvider(at: indexPath).isNotNil else { return }
        cachedSectionHeights[indexPath.section] = nil
        
        prepare()
        invalidateLayout()
    }
}
