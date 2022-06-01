import UIKit

// https://stackoverflow.com/questions/32082726/the-behavior-of-the-uicollectionviewflowlayout-is-not-defined-because-the-cell
final class CellCollectionViewCompositionalLayout: UICollectionViewCompositionalLayout {
    override func shouldInvalidateLayout(forBoundsChange: CGRect) -> Bool {
        return true
    }
}

extension UICollectionViewCompositionalLayout {
    static func flexibleView(
        widthDimension: NSCollectionLayoutDimension = .estimated(20),
        heightDimension: NSCollectionLayoutDimension = .estimated(32),
        interItemSpacing: NSCollectionLayoutSpacing = .fixed(8),
        groundEdgeSpacing: NSCollectionLayoutEdgeSpacing,
        interGroupSpacing: CGFloat = 8
    ) -> UICollectionViewCompositionalLayout {
        CellCollectionViewCompositionalLayout(
            sectionProvider: {
                (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in


                let itemSize = NSCollectionLayoutSize(
                    widthDimension: widthDimension,
                    heightDimension: heightDimension
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .absolute(layoutEnvironment.container.contentSize.width),
                    heightDimension: heightDimension
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.edgeSpacing = groundEdgeSpacing
                group.interItemSpacing = interItemSpacing

                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = interGroupSpacing

                return section
            },
            configuration: UICollectionViewCompositionalLayoutConfiguration()
        )
    }

    static func spreadsheet(
        itemsWidths: [CGFloat],
        views: [[UIView]]
    ) -> UICollectionViewCompositionalLayout {
        CellCollectionViewCompositionalLayout(
            sectionProvider: {
                (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

                var sectionMaxHeight: CGFloat = 0

                let items = itemsWidths.enumerated().map { info -> NSCollectionLayoutItem in
                    guard let view = views[sectionIndex][safe: info.offset] else {
                        return .init(layoutSize: .init(widthDimension: .absolute(info.element), heightDimension: .absolute(32)))
                    }

                    let maxSize = CGSize(width: info.element, height: .greatestFiniteMagnitude)
                    let size = view.systemLayoutSizeFitting(
                        maxSize,
                        withHorizontalFittingPriority: .required,
                        verticalFittingPriority: .fittingSizeLevel
                    )

                    let layoutSize = NSCollectionLayoutSize(
                        widthDimension: .absolute(info.element),
                        heightDimension: .estimated(size.height)
                    )

                    let item = NSCollectionLayoutItem(
                        layoutSize: layoutSize
                    )

//                    item.contentInsets = .init(top: 0.5, leading: 0.5, bottom: 0.5, trailing: 0.5)

                    if sectionMaxHeight < size.height {
                        sectionMaxHeight = size.height
                    }

                    print("+--+ \(size)")

                    return item
                }


                let absoluteWidth = itemsWidths.reduce(0, +)
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .absolute(absoluteWidth),
                    heightDimension: .estimated(sectionMaxHeight)
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: items)

                let section = NSCollectionLayoutSection(group: group)

                return section
            },
            configuration: UICollectionViewCompositionalLayoutConfiguration()
        )
    }
}

extension NSCollectionLayoutEdgeSpacing {
    static var defaultBlockEdgeSpacing: NSCollectionLayoutEdgeSpacing {
        NSCollectionLayoutEdgeSpacing(
            leading: nil,
            top: nil,
            trailing: nil,
            bottom: NSCollectionLayoutSpacing.fixed(0)
        )
    }
}
