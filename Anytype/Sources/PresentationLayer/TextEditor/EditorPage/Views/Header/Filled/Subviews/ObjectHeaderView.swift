//
//  ObjectHeaderView.swift
//  ObjectHeaderView
//
//  Created by Konstantin Mordan on 08.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit
import BlocksModels
import AnytypeCore

final class ObjectHeaderView: UIView {
    
    // MARK: - Private variables

    private let iconView = ObjectHeaderIconView()
    private let coverView = ObjectHeaderCoverView()
    
    private var onIconTap: (() -> Void)?
    private var onCoverTap: (() -> Void)?
    
    private var leadingConstraint: NSLayoutConstraint!
    private var centerConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!

    init(topAdjustedContentInset: CGFloat) {
        super.init(frame: .zero)

        setupView(topAdjustedContentInset: topAdjustedContentInset)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Internal functions
    private var coverViewCenter: CGPoint = .zero

    func applyCoverTransform(_ transform: CGAffineTransform) {
        if coverView.transform.isIdentity {
            coverViewCenter = coverView.layer.position
            coverView.layer.position = CGPoint(x: coverView.frame.midX, y: coverView.frame.maxY)
            coverView.layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        } else if transform.isIdentity {
            coverView.layer.position = coverViewCenter
            coverView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        }

        // Disable CALayer implicit animations
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        coverView.transform = transform

        CATransaction.commit()
    }
}

extension ObjectHeaderView: ConfigurableView {
    
    struct Model {
        let state: ObjectHeaderFilledState
        let width: CGFloat
    }
    
    func configure(model: Model) {
        switch model.state {
        case .iconOnly(let objectHeaderIconState):
            switchState(.icon)
            applyObjectHeaderIcon(objectHeaderIconState.icon)
            onCoverTap = objectHeaderIconState.onCoverTap
            
        case .coverOnly(let objectHeaderCover):
            switchState(.cover)
            
            applyObjectHeaderCover(objectHeaderCover, maxWidth: model.width)
            
        case .iconAndCover(let objectHeaderIcon, let objectHeaderCover):
            switchState(.iconAndCover)
            
            applyObjectHeaderIcon(objectHeaderIcon)
            applyObjectHeaderCover(objectHeaderCover, maxWidth: model.width)
        }
    }
    
    private func switchState(_ state: State) {
        switch state {
        case .icon:
            iconView.isHidden = false
            coverView.isHidden = true
        case .cover:
            iconView.isHidden = true
            coverView.isHidden = false
        case .iconAndCover:
            iconView.isHidden = false
            coverView.isHidden = false
        }
    }
    
    private func applyObjectHeaderIcon(_ objectHeaderIcon: ObjectHeaderIcon) {
        iconView.configure(model: objectHeaderIcon.icon)
        applyLayoutAlignment(objectHeaderIcon.layoutAlignment)
        onIconTap = objectHeaderIcon.onTap
    }
    
    private func applyLayoutAlignment(_ layoutAlignment: LayoutAlignment) {
        switch layoutAlignment {
        case .left:
            leadingConstraint.isActive = true
            centerConstraint.isActive = false
            trailingConstraint.isActive = false
        case .center:
            leadingConstraint.isActive = false
            centerConstraint.isActive = true
            trailingConstraint.isActive = false
        case .right:
            leadingConstraint.isActive = false
            centerConstraint.isActive = false
            trailingConstraint.isActive = true
        }
    }
    
    private func applyObjectHeaderCover(_ objectHeaderCover: ObjectHeaderCover, maxWidth: CGFloat) {
        coverView.configure(
            model: ObjectHeaderCoverView.Model(
                objectCover: objectHeaderCover.coverType,
                size: CGSize(
                    width: maxWidth,
                    height: Constants.coverHeight
                )
            )
        )
        onCoverTap = objectHeaderCover.onTap
    }
    
}

private extension ObjectHeaderView {
    
    func setupView(topAdjustedContentInset: CGFloat) {
        backgroundColor = .backgroundPrimary
        setupGestureRecognizers()
        
        setupLayout(topAdjustedContentInset: topAdjustedContentInset)
        
        iconView.isHidden = true
        coverView.isHidden = true
    }
    
    func setupGestureRecognizers() {
        iconView.addGestureRecognizer(
            TapGestureRecognizerWithClosure { [weak self] in
                self?.onIconTap?()
            }
        )
        
        addGestureRecognizer(
            TapGestureRecognizerWithClosure { [weak self] in
                self?.onCoverTap?()
            }
        )
    }
    
    func setupLayout(topAdjustedContentInset: CGFloat) {
        layoutUsing.anchors {
            $0.height.equal(to: Constants.height, priority: .defaultLow)
        }
        
        addSubview(coverView) {
            $0.pinToSuperview(excluding: [.top, .bottom])
            $0.bottom.equal(to: bottomAnchor, constant: -Constants.coverBottomInset)
            $0.height.equal(to: Constants.coverHeight + topAdjustedContentInset)
        }
        
        addSubview(iconView) {
            $0.bottom.equal(
                to: bottomAnchor,
                constant: -Constants.iconBottomInset
            )

            leadingConstraint = $0.leading.equal(
                to: leadingAnchor,
                constant: Constants.iconHorizontalInset,
                activate: false
            )

            centerConstraint = $0.centerX.equal(
                to: centerXAnchor,
                activate: false
            )
            
            trailingConstraint =  $0.trailing.equal(
                to: trailingAnchor,
                constant: -Constants.iconHorizontalInset,
                activate: false
            )
        }
    }
    
}

private extension ObjectHeaderView {
    
    enum State {
        case icon
        case cover
        case iconAndCover
    }
    
}

extension ObjectHeaderView {
    
    enum Constants {
        static let height: CGFloat = 172
        static let coverHeight = Constants.height - Constants.coverBottomInset
        static let coverBottomInset: CGFloat = 32
        
        static let iconHorizontalInset: CGFloat = 20 - ObjectHeaderIconView.Constants.borderWidth
        static let iconBottomInset: CGFloat = 16 - ObjectHeaderIconView.Constants.borderWidth
    }
    
}
