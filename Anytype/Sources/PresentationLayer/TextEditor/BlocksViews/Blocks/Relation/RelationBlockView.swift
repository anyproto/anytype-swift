import UIKit
import SwiftUI

final class RelationBlockView: UIView, BlockContentView {
    private var bottomConstraint: NSLayoutConstraint!

    // MARK: - Views
    private let relationValueView = RelationValueViewUIKit()

    private let relationNameView = AnytypeLabel(style: .relation1Regular)
    private let relationLockedView = UIImageView(asset: .relationLocked)
    private let containerView = UIView()
    private let relationNameStack = UIStackView()

    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }
    
    func update(with state: UICellConfigurationState) {
        relationValueView.isUserInteractionEnabled = !state.isLocked
    }

    func update(with configuration: RelationBlockContentConfiguration) {
        relationNameView.setText(configuration.relation.name)
        relationLockedView.isHidden = configuration.relation.isEditable
        relationValueView.update(
            with: .init(
                relation: configuration.relation,
                style: .regular(allowMultiLine: true),
                action: configuration.actionOnValue
            )
        )
    }

    // MARK: - Setup view

    private func setupLayout() {
        relationNameStack.axis = .horizontal
        relationNameStack.spacing = 6
        relationNameStack.alignment = .center

        relationNameStack.addArrangedSubview(relationLockedView)
        relationNameStack.addArrangedSubview(relationNameView)

        relationLockedView.layoutUsing.anchors {
            $0.width.equal(to: 10)
            $0.height.equal(to: 13)
        }

        relationNameView.textColor = .textSecondary

        addSubview(containerView) {
            $0.pinToSuperview()
        }
        containerView.addSubview(relationNameStack) {
            $0.top.equal(to: containerView.topAnchor, constant: LayoutConstants.topBottomInset)
            $0.leading.equal(to: containerView.leadingAnchor)
            $0.width.equal(to: containerView.widthAnchor, multiplier: 0.4)
        }

        containerView.addSubview(relationValueView) {
            $0.pinToSuperview(
                excluding: [.left],
                insets: UIEdgeInsets(
                    top: LayoutConstants.topBottomInset,
                    left: 0,
                    bottom: -LayoutConstants.topBottomInset,
                    right: 0
                )
            )
            $0.leading.equal(to: relationNameView.trailingAnchor, constant: 2)
        }
    }

    private enum LayoutConstants {
        static let topBottomInset: CGFloat = 6
    }
}
