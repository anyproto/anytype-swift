import UIKit
import Combine
import AnytypeCore

protocol RelativePositionProvider: AnyObject {
    var contentOffsetDidChangedStatePublisher: AnyPublisher<CGPoint, Never> { get }

    func visibleRect(to view: UIView) -> CGRect
}

final class SpreadsheetLayout: UICollectionViewLayout {
    private weak var dataSource: SpreadsheetViewDataSource?

    var currentVisibleRect: CGRect = .zero
    weak var relativePositionProvider: RelativePositionProvider? {
        didSet {
            relativePositionProvider?
                .contentOffsetDidChangedStatePublisher
                .sink { [weak self] _ in
                    self?.invalidateLayout(with: SpreadsheetInvalidationContext())
                }.store(in: &cancellables)
        }
    }
    private var cancellables = [AnyCancellable]()

    var itemWidths = [CGFloat]() {
        didSet {
            reset()
        }
    }

    private var selection: SimpleTableMenuView.Tab = .cell
    private var cachedSectionRowHeights = [AnyHashable: CGFloat]()
    private var cachedSectionHeights = [Int: CGFloat]()
    private var attributes: [UICollectionViewLayoutAttributes] = []
    private var contentSize = CGSize.zero
    private lazy var selectionAttributes = SelectionDecorationAttributes(
        forSupplementaryViewOfKind: SelectionDecorationView.reusableIdentifier,
        with: IndexPath(row: 0, section: 0)
    )

    override var collectionViewContentSize: CGSize { contentSize }

    override class var invalidationContextClass: AnyClass {
        SpreadsheetInvalidationContext.self
    }

    private var lastHashableItems = 0
    private var lastSelectedIndexPaths = [IndexPath]()

    init(dataSource: SpreadsheetViewDataSource) {
        self.dataSource = dataSource

        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutAttributesForElements(
        in rect: CGRect
    ) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView,
              let visibleRect = relativePositionProvider?.visibleRect(to: collectionView)  else {
            return nil
        }

        let height: CGFloat
        let y: CGFloat
        if visibleRect.origin.y < 0 {
            y = 0
            height = visibleRect.size.height + visibleRect.origin.y
        } else {
            y = visibleRect.origin.y
            height = visibleRect.size.height
        }

        let newRect = CGRect(x: rect.origin.x, y: y, width: rect.width, height: height)
        let attributes = (attributes + [selectionAttributes]).filter { $0.frame.intersects(newRect) }


        return attributes
    }
    
    func reselectSelectedCells(selection: SimpleTableMenuView.Tab) {
        self.selection = selection
        guard let collectionView = collectionView else { return }
        let selectedIndexPaths = collectionView.indexPathsForSelectedItems ?? []

        // Bad implementation
        guard lastHashableItems != attributes.hashValue || lastSelectedIndexPaths != selectedIndexPaths else {
            return
        }

        let unionIndexPaths = SpreadsheetSelectionHelper.groupSelected(indexPaths: selectedIndexPaths)

        selectionAttributes.selectedRects = unionIndexPaths.map { indexPaths in // It could be slow. Need improvements.
            indexPaths.compactMap { indexPath in
                let attribute = attributes.first(where: { $0.indexPath == indexPath })

                return attribute?.frame ?? .zero
            }
        }

        self.lastSelectedIndexPaths = selectedIndexPaths

    }

    override func prepare() {
        guard let collectionView = collectionView, let dataSource = dataSource else {
            return
        }

        for sectionIndex in 0..<collectionView.numberOfSections {
            var sectionMaxHeight: CGFloat = 0

            for rowIndex in 0..<collectionView.numberOfItems(inSection: sectionIndex) {
                let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
                let columnWidth = itemWidths[rowIndex]

                guard let item = dataSource.contentConfigurationProvider(at: indexPath) else {
                    continue
                }
                let hashable = item.spreadsheethashable(width: columnWidth)

                let size: CGSize
                if let cachedValue = cachedSectionRowHeights[hashable] {
                    size = .init(width: columnWidth, height: cachedValue)
                } else {
                    let cell = dataSource.dequeueCell(at: indexPath)

                    let maxSize = CGSize(
                        width: columnWidth,
                        height: .greatestFiniteMagnitude
                    )
                    size = cell.systemLayoutSizeFitting(
                        maxSize,
                        withHorizontalFittingPriority: .required,
                        verticalFittingPriority: .fittingSizeLevel
                    )

                    cachedSectionRowHeights[hashable] = size.height
                }

                sectionMaxHeight = size.height > sectionMaxHeight ? size.height : sectionMaxHeight
            }

            cachedSectionHeights[sectionIndex] = sectionMaxHeight
        }

        reloadAttributesCache()
    }

    private func reset() {
        cachedSectionHeights.removeAll()
    }

    private func reloadAttributesCache() {
        attributes.removeAll()

        guard let collectionView = collectionView else { return }

        var fullHeight: CGFloat = 0
        var originY: CGFloat = 2
        for sectionIndex in 0..<collectionView.numberOfSections {
            guard let maxSectionHeight = cachedSectionHeights[sectionIndex] else {
                        anytypeAssertionFailure(
                            "Reload attributes cache broken logic",
                            domain: .simpleTables
                        )
                        return
                    }

            var originX: CGFloat = 2
            fullHeight = fullHeight + maxSectionHeight

            for row in 0..<collectionView.numberOfItems(inSection: sectionIndex) {
                let rowWidth = itemWidths[row]
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

        contentSize = .init(width: itemWidths.reduce(0, +) + 4, height: fullHeight + 10 + 2)

        reselectSelectedCells(selection: selection)

        self.lastHashableItems = attributes.hashValue
    }
}

extension SpreadsheetLayout {
    func setNeedsLayout(indexPath: IndexPath) {
        guard let dataSource = dataSource,
              let item = dataSource.contentConfigurationProvider(at: indexPath) else { return }
        cachedSectionHeights[indexPath.section] = nil

        let existingCell = dataSource.dequeueCell(at: indexPath)

        let columnWidth = itemWidths[indexPath.row]

        let maxSize = CGSize(
            width: columnWidth,
            height: .greatestFiniteMagnitude
        )
        let size = existingCell.systemLayoutSizeFitting(
            maxSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        let hashable = item.spreadsheethashable(width: columnWidth)

        cachedSectionRowHeights[hashable] = size.height
        prepare()
        invalidateLayout()
    }
}


private extension ContentConfigurationProvider {
    func spreadsheethashable(width: CGFloat) -> AnyHashable {
        return [hashable, width as AnyHashable]
    }
}
