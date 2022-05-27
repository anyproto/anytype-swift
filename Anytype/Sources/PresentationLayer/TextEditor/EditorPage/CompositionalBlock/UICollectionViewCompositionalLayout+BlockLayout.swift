import UIKit

extension UICollectionViewCompositionalLayout {
    static func flexibleView(
        widthDimension: NSCollectionLayoutDimension = .estimated(20),
        heightDimension: NSCollectionLayoutDimension = .estimated(32),
        interItemSpacing: NSCollectionLayoutSpacing = .fixed(8),
        groundEdgeSpacing: NSCollectionLayoutEdgeSpacing,
        interGroupSpacing: CGFloat = 8
    ) -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout(
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
