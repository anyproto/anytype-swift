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
    
    var onCoverTap: (() -> Void)?
    var onIconTap: (() -> Void)?
    
    // MARK: - Private variables

    private let iconView = ObjectHeaderIconView()
    private let coverView = ObjectCoverView()
    
    private var leadingConstraint: NSLayoutConstraint!
    private var centerConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!
        
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Internal functions
    
    func applyCoverTransform(_ transform: CGAffineTransform) {
        coverView.transform = transform
    }
    
}

extension ObjectHeaderView: ConfigurableView {
    
    struct Model {
        let header: ObjectHeader
        let width: CGFloat
    }
    
    func configure(model: Model) {
        switch model.header {
        case .iconOnly(let objectIcon):
            setupState(.icon)
            
            iconView.configure(
                model: objectIcon.icon
            )
            
            handleIconLayoutAlignment(objectIcon.layoutAlignment)
            
        case .coverOnly(let objectCover):
            setupState(.cover)
            
            coverView.configure(
                model: ObjectCoverView.Model(
                    objectCover: objectCover,
                    size: CGSize(
                        width: model.width,
                        height: Constants.height
                    )
                )
            )
            
        case .iconAndCover(let objectIcon, let objectCover):
            setupState(.iconAndCover)
            
            iconView.configure(model: objectIcon.icon)
            coverView.configure(
                model: ObjectCoverView.Model(
                    objectCover: objectCover,
                    size: CGSize(
                        width: model.width,
                        height: Constants.height
                    )
                )
            )
            
            handleIconLayoutAlignment(objectIcon.layoutAlignment)
            
        case .empty:
            anytypeAssertionFailure("Not supported")
            break
        }
    }
    
}

private extension ObjectHeaderView {
    
    func setupView() {
        backgroundColor = .backgroundPrimary
        setupGestureRecognizers()
        
        setupLayout()
        
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
    
    func setupLayout() {
        layoutUsing.anchors {
            $0.height.equal(to: Constants.height)
        }
        
        addSubview(coverView) {
            $0.pinToSuperview(excluding: [.bottom])
            $0.height.equal(to: Constants.coverHeight)
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
    
    func setupState(_ state: State) {
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
    
    func handleIconLayoutAlignment(_ layoutAlignment: LayoutAlignment) {
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
        static let height: CGFloat = 264
        static let coverHeight = Constants.height - Constants.coverBottomInset
        static let coverBottomInset: CGFloat = 32
        
        static let iconHorizontalInset: CGFloat = 20 - ObjectHeaderIconView.Constants.borderWidth
        static let iconBottomInset: CGFloat = 16 - ObjectHeaderIconView.Constants.borderWidth
    }
    
}
