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
            $0.pinToSuperview(insets: .init(top: 0, left: 2, bottom: 0, right: 0))
        }
    }

    func update(with configuration: FeaturedRelationsBlockContentConfiguration) {
        let views = configuration.featuredRelations.map {
            RelationValueViewUIKit(
                relation: $0,
                style: .featuredRelationBlock(allowMultiLine: false),
                action: configuration.onRelationTap
            )
        }

        blocksView.update(
            with: .init(
                hashable: AnyHashable(configuration),
                compositionalLayout: .flexibleView(groundEdgeSpacing: .defaultBlockEdgeSpacing),
                views: views,
                heightDidChanged: configuration.heightDidChanged
            )
        )
    }
}
