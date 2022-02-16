import UIKit
import SwiftUI

final class RelationBlockView: UIView, BlockContentView, ObservableObject {
    private var bottomConstraint: NSLayoutConstraint!

    // MARK: - Views
    private lazy var relationValueView = RelationValueViewUIKit(relation: .unknown(.empty(id: "", name: "")),
                                                               style: .regular(allowMultiLine: true),
                                                               action: nil)

    private let relationNameView = AnytypeLabel(style: .relation1Regular)
    private let containerView = UIView()

    // MARK: - BaseBlockView
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }

    override func update(with configuration: RelationBlockContentConfiguration) {
        //        relation = configuration.relation
        //        actionOnValue = configuration.actionOnValue

//        super.update(with: configuration)
//
//        relationValueView.removeFromSuperview()
//        relationValueView = RelationValueViewUIKit(relation: configuration.relation,
//                                                   style: .regular(allowMultiLine: true),
//                                                   action: configuration.actionOnValue)
//
//        relationNameView.setText(configuration.relation.name)
//
//        containerView.addSubview(relationValueView) {
//            $0.pinToSuperview(excluding: [.left], insets: UIEdgeInsets(top: LayoutConstants.topBottomInset,
//                                                                       left: 0,
//                                                                       bottom: -LayoutConstants.topBottomInset,
//                                                                       right: 0))
//            $0.leading.equal(to: relationNameView.trailingAnchor, constant: 2)
//        }
    }

    // MARK: - Setup view

    private func setupLayout() {
        relationNameView.textColor = .textSecondary

        addSubview(containerView) {
            $0.pinToSuperview(insets: UIEdgeInsets(top: 0,
                                                   left: 20,
                                                   bottom: 0,
                                                   right: -20))
        }
        containerView.addSubview(relationNameView) {
            $0.top.equal(to: containerView.topAnchor, constant: LayoutConstants.topBottomInset)
            $0.leading.equal(to: containerView.leadingAnchor)
            $0.width.equal(to: containerView.widthAnchor, multiplier: 0.4)
        }
        containerView.addSubview(relationValueView) {
            $0.pinToSuperview(excluding: [.left], insets: UIEdgeInsets(top: LayoutConstants.topBottomInset,
                                                                       left: 0,
                                                                       bottom: -LayoutConstants.topBottomInset,
                                                                       right: 0))
            $0.leading.equal(to: relationNameView.trailingAnchor, constant: 2)
        }
    }

    private enum LayoutConstants {
        static let topBottomInset: CGFloat = 6
    }
}
