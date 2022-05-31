import Foundation
import UIKit
import SwiftUI

final class FeaturedRelationBlockView: UIView, BlockContentView {
    private lazy var blocksView = DynamicCompositionalLayoutView(frame: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupSubview()
    }

    private var configuration: Configuration?

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
        var views = [UIView]()

        self.configuration = configuration

        configuration.featuredRelations.forEach { item in
            let relationView = RelationValueViewUIKit(
                relation: item,
                style: .featuredRelationBlock(allowMultiLine: true),
                action: configuration.onRelationTap
            )

            relationView.backgroundColor = .randomColor()

            views.append(relationView)

            if item != configuration.featuredRelations.last {
                let textView = UITextView()

//                textView.numberOfLines = 0
                textView.text = "Lorem ipsum dolor sit amet"
//                label.textColor = .textSecondary
//                label.font = .systemFont(ofSize: 13)
                textView.backgroundColor = .randomColor()
                textView.delegate = self
                textView.isScrollEnabled = false


//                let heightConstraint = label.heightAnchor.constraint(equalToConstant: 18)
//                heightConstraint.priority = .defaultLow
//                heightConstraint.isActive = true

//                label.translatesAutoresizingMaskIntoConstraints = false

                views.append(textView)
            }


//            DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [unowned self] in
//                self.blocksView.collectionView.collectionViewLayout.invalidateLayout()
//                self.blocksView.collectionView.collectionViewLayout.prepare()
//
//            }


        }

        

        blocksView.update(
            with: .init(
                hashable: AnyHashable(configuration),
                compositionalLayout: .staticWidth(width: 100, fullWidth: 400, groundEdgeSpacing: NSCollectionLayoutEdgeSpacing.defaultBlockEdgeSpacing),
                views: views,
                heightDidChanged: configuration.heightDidChanged
            )
        )
    }
}

extension FeaturedRelationBlockView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        blocksView.collectionView.collectionViewLayout.invalidateLayout()
        blocksView.collectionView.collectionViewLayout.prepare()
        configuration?.heightDidChanged()

        return true
    }
}
