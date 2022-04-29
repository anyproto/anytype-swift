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

    func update(with configuration: FeaturedRelationsBlockContentConfiguration) {
        var views = [UIView]()

        configuration.featuredRelations.forEach { item in
            let relationView = RelationValueViewUIKit(
                relation: item,
                style: .featuredRelationBlock(allowMultiLine: false),
                action: configuration.onRelationTap
            )

            views.append(relationView)

            if item != configuration.featuredRelations.last {
                let label = UILabel()

                label.text = "•"
                label.textColor = .textSecondary
                label.font = .systemFont(ofSize: 16)

                let heightConstraint = label.heightAnchor.constraint(equalToConstant: 18)
                heightConstraint.priority = .defaultLow
                heightConstraint.isActive = true

                label.translatesAutoresizingMaskIntoConstraints = false

                views.append(label)
            }
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
