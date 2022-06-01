import Foundation
import UIKit
import SwiftUI

final class FeaturedRelationBlockView: UIView, BlockContentView {
    private lazy var blocksView = DynamicCompositionalLayoutView(frame: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupSubview()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupSubview()
    }

    func setupSubview() {
        addSubview(blocksView) {
            $0.pinToSuperview(
                insets: .init(top: 8, left: 0, bottom: 0, right: 0)
            )
        }
    }

    func update(with state: UICellConfigurationState) {
        blocksView.isUserInteractionEnabled = !state.isLocked
    }

    func update(with configuration: FeaturedRelationsBlockContentConfiguration) {
//        var compositionalModels = [CompositionalClass]()

//        configuration.featuredRelations.forEach { item in
//            let configuration = RelationValueViewConfiguration(
//                relation: item,
//                style: .featuredRelationBlock(allowMultiLine: false),
//                action: configuration.onRelationTap
//            )
//
//            compositionalModels.append(.init(item: <#T##BlockConfiguration#>, backgroundColor: <#T##UIColor?#>, width: <#T##CGFloat#>))
//
//            if item != configuration.relation.last {
//
//                let separatorConfiguration = SeparatorItemConfiguration(style: .dot, height: 18)
//
//
//                compositionalModels.append(label)
//            }
//        }




//        blocksView.update(
//            with: .init(
//                hashable: AnyHashable(configuration),
//                compositionalLayout: .flexibleView(groundEdgeSpacing: .defaultBlockEdgeSpacing),
//                views: [views],
//                heightDidChanged: configuration.heightDidChanged
//            )
//        )
    }
}

