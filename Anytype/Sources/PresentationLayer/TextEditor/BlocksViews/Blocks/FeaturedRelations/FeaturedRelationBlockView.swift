import Foundation
import UIKit
import SwiftUI

final class FeaturedRelationBlockView: UIView, BlockContentView {
    private let blocksView = DynamicCollectionLayoutView(frame: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupSubview()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupSubview()
    }

    func update(with state: UICellConfigurationState) {
        blocksView.isUserInteractionEnabled = !state.isLocked
    }

    func update(with configuration: FeaturedRelationsBlockContentConfiguration) {
//        var dequebale = [Dequebale]()

//        configuration.featuredRelations.forEach {
//            let valueViewConfiguration = RelationValueViewConfiguration(
//                relation: $0,
//                style: .featuredRelationBlock(allowMultiLine: false),
//                action: configuration.onRelationTap
//            )
//
//            dequebale.append(valueViewConfiguration)
//
//            let separatorConfiguration = SeparatorItemConfiguration(style: .dot, height: 18)
//
//            if $0 != configuration.featuredRelations.last {
//                dequebale.append(separatorConfiguration)
//            }
//        }
//
//        let layout = UICollectionViewCompositionalLayout.flexibleView(groundEdgeSpacing: .defaultBlockEdgeSpacing)
//
//        blocksView.update(
//            with: .init(
//                hashable: configuration,
//                dataSource: .init(views: [dequebale]),
//                layout: layout,
//                heightDidChanged: configuration.heightDidChanged
//            )
//        )
    }

    private func setupSubview() {
        setupLayout()

//        blocksView.collectionView.register(
//            GenericCollectionViewCell<RelationValueViewUIKit>.self,
//            forCellWithReuseIdentifier: RelationValueViewUIKit.reusableIdentifier
//        )
//
//        blocksView.collectionView.register(
//            GenericCollectionViewCell<SeparatorItemView>.self,
//            forCellWithReuseIdentifier: SeparatorItemView.reusableIdentifier
//        )
    }

    private func setupLayout() {
        addSubview(blocksView) {
            $0.pinToSuperview(
                insets: .init(top: 8, left: 0, bottom: 0, right: 0)
            )
        }
    }
}

