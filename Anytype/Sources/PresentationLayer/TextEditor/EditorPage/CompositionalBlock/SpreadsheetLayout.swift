import UIKit
import Combine
import AnytypeCore

protocol RelativePositionProvider: AnyObject {
    var contentOffsetDidChangedStatePublisher: AnyPublisher<CGPoint, Never> { get }

    func visibleRect(to view: UIView) -> CGRect
}

final class SpreadsheetLayout: UICollectionViewLayout {
    var items: [[Dequebale]]?
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
            invalidateLayout()
        }
    }

    private var cachedSectionRowHeights = [Int: [Int: CGSize]]()
    private var cachedSectionHeights = [Int: CGFloat]()
    private var attributes: [UICollectionViewLayoutAttributes] = []
    private var contentSize = CGSize.zero

    override var collectionViewContentSize: CGSize { contentSize }

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

        let attributes = attributes.filter { $0.frame.intersects(newRect) }

        return attributes
    }

    override func prepare() {
        guard let collectionView = collectionView, let items = items else {
            return
        }

        for sectionIndex in 0..<collectionView.numberOfSections {
            for row in 0..<collectionView.numberOfItems(inSection: sectionIndex) {
                let indexPath = IndexPath(row: row, section: sectionIndex)

                let size: CGSize

                if let cachedValue = cachedSectionRowHeights[sectionIndex],
                    let cachedSize = cachedValue[row] {
                    size = cachedSize
                } else {
                    let cell = items[sectionIndex][row].dequeueReusableCell(
                        collectionView: collectionView,
                        for: indexPath
                    )

                    let columnWidth = itemWidths[row]

                    let maxSize = CGSize(
                        width: columnWidth,
                        height: .greatestFiniteMagnitude
                    )
                    size = cell.systemLayoutSizeFitting(
                        maxSize,
                        withHorizontalFittingPriority: .required,
                        verticalFittingPriority: .fittingSizeLevel
                    )

                    if var sectionRowHeights = cachedSectionRowHeights[sectionIndex] {
                        sectionRowHeights[row] = size
                        cachedSectionRowHeights[sectionIndex] = sectionRowHeights
                    } else {
                        cachedSectionRowHeights[sectionIndex] = [row: size]
                    }
                }
            }
        }

        reloadAttributesCache()
    }

    private func reloadAttributesCache() {
        attributes.removeAll()

        guard let collectionView = collectionView else { return }

        var fullHeight: CGFloat = 0
        var originY: CGFloat = 0
        for sectionIndex in 0..<collectionView.numberOfSections {
            guard let maxSectionHeight = cachedSectionRowHeights[sectionIndex]?
                    .values
                    .map(\.height)
                    .max() else {
                        anytypeAssertionFailure(
                            "Reload attributes cache broken logic",
                            domain: .simpleTables
                        )
                        return
                    }

            var originX: CGFloat = 0
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

        contentSize = .init(width: itemWidths.reduce(0, +), height: fullHeight)
    }
}
