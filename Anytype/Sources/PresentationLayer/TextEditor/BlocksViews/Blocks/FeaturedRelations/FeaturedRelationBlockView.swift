import Foundation
import UIKit
import SwiftUI

final class FeaturedRelationBlockView: UIView, BlockContentView {
    private let blocksView = DynamicCollectionLayoutView(frame: .zero)
    private lazy var dataSource = FeaturedRelationBlockItemsDataSource(collectionView: blocksView.collectionView)

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupSubview()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupSubview()
    }

    func update(with configuration: FeaturedRelationsBlockContentConfiguration) {
        var dequebale = [Dequebale]()

        configuration.featuredRelations.forEach {
            let valueViewConfiguration = RelationValueViewConfiguration(
                relation: $0,
                style: .featuredRelationBlock(
                    FeaturedRelationSettings(
                        allowMultiLine: false,
                        error: $0.isErrorState,
                        links: $0.links
                    )
                ),
                action: configuration.onRelationTap
            )

            dequebale.append(valueViewConfiguration)

            let separatorConfiguration = SeparatorItemConfiguration(style: .dot, height: 18)

            if $0 != configuration.featuredRelations.last {
                dequebale.append(separatorConfiguration)
            }
        }

        let layout = UICollectionViewCompositionalLayout.flexibleView(groundEdgeSpacing: .defaultBlockEdgeSpacing)

        blocksView.update(
            with: .init(
                layoutHeightMemory: .hashable(configuration),
                layout: layout,
                heightDidChanged: configuration.heightDidChanged
            )
        )

        dataSource.items = dequebale // It is important to updates items after layout change!
    }

    private func setupSubview() {
        setupLayout()
    }

    private func setupLayout() {
        addSubview(blocksView) {
            $0.pinToSuperview(
                insets: .init(top: 8, left: 0, bottom: 0, right: 0)
            )
        }
    }
}
