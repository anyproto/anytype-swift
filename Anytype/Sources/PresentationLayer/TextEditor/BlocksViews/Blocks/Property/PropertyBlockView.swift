import UIKit
import SwiftUI

final class PropertyBlockView: UIView, BlockContentView {
    // MARK: - Views
    private let relationValueView = PropertyValueViewUIKit()

    private let relationNameView = AnytypeLabel(style: .relation1Regular)
    private let relationIcon = UIImageView()
    private let containerView = UIView()

    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }

    func update(with configuration: PropertyBlockContentConfiguration) {
        if !configuration.property.isDeleted {
            setupRelationState(property: configuration.property, action: configuration.actionOnValue)
        } else {
            setupDeletedState()
        }
    }

    // MARK: - Setup view
    
    private func setupDeletedState() {
        relationNameView.setText(Loc.Relation.deleted)
        relationIcon.image = UIImage(asset: .ghost)
        relationIcon.isHidden = false
        relationValueView.update(with: PropertyValueViewConfiguration(
            property: nil,
            style: .regular(allowMultiLine: false),
            action: nil
        ))
    }
    
    private func setupRelationState(
        property: PropertyItemModel,
        action: (() -> Void)?
    ) {
        relationNameView.setText(property.name)
        relationIcon.image = UIImage(asset: .relationLocked)
        relationIcon.tintColor = .Control.active
        relationIcon.isHidden = property.isEditable
        relationValueView.update(
            with: .init(
                property: property,
                style: .regular(allowMultiLine: true),
                action: action
            )
        )
    }

    private func setupLayout() {
        
        addSubview(containerView) {
            $0.pinToSuperview()
        }
        
        let relationNameStack = UIView()
        
        relationNameStack.layoutUsing.stack {
            $0.hStack(
                spacing: 3,
                alignedTo: .top,
                relationIcon,
                $0.vStack(
                    $0.vGap(fixed: 2),
                    relationNameView,
                    $0.vGap(fixed: 2)
                )
            )
        }
        
        containerView.layoutUsing.stack {
            $0.edgesToSuperview(
                insets: UIEdgeInsets(
                    top: LayoutConstants.topBottomInset,
                    left: 0,
                    bottom: LayoutConstants.topBottomInset,
                    right: 0
                )
            )
        } builder: {
            $0.hStack(
                spacing: 12,
                alignedTo: .leading,
                relationNameStack,
                $0.vStack(
                    $0.vGap(fixed: 2),
                    relationValueView,
                    $0.vGap(fixed: 2)
                )
            )
        }
        
        relationIcon.contentMode = .center
        relationIcon.layoutUsing.anchors {
            $0.width.equal(to: 24)
            $0.height.equal(to: 24)
        }
        
        relationNameView.textColor = .Text.secondary
        relationNameStack.layoutUsing.anchors {
            $0.width.equal(to: containerView.widthAnchor, multiplier: 0.4)
        }
    }

    private enum LayoutConstants {
        static let topBottomInset: CGFloat = 6
    }
}
