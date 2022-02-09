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

    func update(with configuration: RelationBlockContentConfiguration) {
//        relation = configuration.relation
//        actionOnValue = configuration.actionOnValue

//        relationValueView.removeFromSuperview()
//        relationValueView = RelationValueViewUIKit(relation: configuration.relation,
//                                                   style: .regular(allowMultiLine: true),
//                                                   action: configuration.actionOnValue)
//
//        relationNameView.setText(configuration.relation.name)
//
//        containerView.addSubview(relationValueView) {
//            $0.pinToSuperview(excluding: [.left])
//            $0.leading.equal(to: relationNameView.trailingAnchor, constant: 2)
//        }
    }

    // MARK: - Setup view

    private func setupLayout() {
        relationNameView.textColor = .textSecondary

        addSubview(containerView) {
            $0.pinToSuperview(excluding: [.bottom], insets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: -20))
            bottomConstraint = $0.bottom.equal(to: bottomAnchor, constant: -2, priority: .defaultLow)
            $0.height.greaterThanOrEqual(to: LayoutConstants.minHeight)
        }
        containerView.addSubview(relationNameView) {
            $0.pinToSuperview(excluding: [.right, .bottom])
            $0.width.equal(to: containerView.widthAnchor, multiplier: 0.4)
            $0.height.greaterThanOrEqual(to: LayoutConstants.minHeight)
        }
        containerView.addSubview(relationValueView) {
            $0.pinToSuperview(excluding: [.left])
            $0.leading.equal(to: relationNameView.trailingAnchor, constant: 2)
        }
    }

    private enum LayoutConstants {
        static let minHeight: CGFloat = 32
    }
}
